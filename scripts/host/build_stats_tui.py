#!/usr/bin/env python3

# Terminal graphs of logs/builds.log (see buildlog): each nightly run's time
# and energy, how far each target's newest package is behind the kismet
# source, and each target's builds over time.
#
# Usage: build_stats_tui.py [--once] [base] [src] [log]
#   --once  print the graphs and exit instead of running interactively
#   base    kismet-packages directory
#   src     kismet source tree the builds use
#   log     build log to read (default [base]/logs/builds.log)
#
# Keys: m/M history metric, r run metric, arrows/pgup/pgdn scroll, g reload,
# q quit.  The log is re-read every minute.

import curses
import os
import re
import shutil
import subprocess
import sys
import time
from datetime import datetime

FIELD = re.compile(r'([A-Za-z0-9_]+)=("(?:[^"\\]|\\.)*"|\S*)')

VBLOCKS = " ▁▂▃▄▅▆▇█"
HBLOCKS = " ▏▎▍▌▋▊▉█"

NAME_W = 22
CHART_H = 6
RUNNING_S = 4 * 3600


def parse(line):
    rec = {}
    for k, v in FIELD.findall(line):
        if v.startswith('"'):
            v = re.sub(r'\\(.)', r'\1', v[1:-1])
        rec[k] = v
    return rec


def val(r, k):
    try:
        return int(r.get(k, ""))
    except ValueError:
        return None


def hms(s):
    return f"{s // 3600}:{s % 3600 // 60:02d}:{s % 60:02d}"


def short(v):
    for div, suffix in ((1e9, "G"), (1e6, "M"), (1e3, "k")):
        if v >= div:
            return f"{v / div:.0f}{suffix}" if v >= div * 10 else f"{v / div:.1f}{suffix}"
    return str(v)


def span(s):
    if s < 3600:
        return f"{s // 60}m"
    if s < 2 * 86400:
        return f"{s // 3600}h"
    return f"{s // 86400}d"


def stamp(ts):
    try:
        return datetime.fromisoformat(ts).timestamp()
    except (TypeError, ValueError):
        return None


def day(ts):
    t = stamp(ts)
    return datetime.fromtimestamp(t).strftime("%m-%d") if t else "?"


def ago(ts):
    t = stamp(ts)
    return f"{span(max(int(time.time() - t), 0))} ago" if t else "?"


TARGET_METRICS = [
    ("behind", "commits behind current source", str),
    ("duration_s", "build time", hms),
    ("cpu_s", "CPU time", hms),
    ("energy_j", "CPU energy", lambda v: f"{v / 1000:.0f} kJ"),
    ("warnings", "compiler warnings", str),
    ("mem_peak_mb", "peak memory", lambda v: f"{v / 1024:.1f} GB"),
    ("deb_kb", "package size", lambda v: f"{v / 1024:.0f} MB"),
]

RUN_METRICS = [
    ("duration_s", "run time", hms),
    ("energy_j", "CPU energy", lambda v: f"{v / 1000:.0f}kJ"),
    ("built", "targets built", str),
]


class Stats:
    def __init__(self, base, src, log):
        self.base, self.src, self.log = base, src, log
        self.load()

    def git(self, *args):
        try:
            p = subprocess.run(["git", "-C", self.src, *args], capture_output=True, text=True)
        except OSError:
            return None
        return p.stdout.strip() if p.returncode == 0 else None

    def load(self):
        self.error = None
        try:
            with open(self.log) as f:
                recs = [parse(l) for l in f if l.strip()]
        except OSError as e:
            self.error = f"Can't read {self.log}: {e.strerror}"
            recs = []

        self.targets = [r for r in recs if r.get("type") == "target" and r.get("target")]
        self.runs = [r for r in recs if r.get("type") == "run"]
        self.head = self.git("rev-parse", "--short", "HEAD")
        self.head_desc = self.git("log", "-1", "--format=%s (%cr)") or ""
        ct = self.git("log", "-1", "--format=%ct")
        self.head_time = int(ct) if ct and ct.isdigit() else None
        self._behind = {}

        # One column per run, oldest first; builds outside a run get their own
        self.columns = []
        self.cells = {}
        for r in self.targets:
            key = r.get("run") or f"single {r.get('ts', '')}"
            if key not in self.cells:
                self.columns.append((key, r.get("ts", "")))
                self.cells[key] = {}
            self.cells[key][r["target"]] = r

        self.names = sorted({r["target"] for r in self.targets})
        self.latest = {}
        self.built = {}
        for r in self.targets:
            self.latest[r["target"]] = r
            if r.get("status") == "built":
                self.built[r["target"]] = r

        done = {r.get("run") for r in self.runs}
        self.running = None
        for key, ts in reversed(self.columns):
            t = stamp(ts)
            if key.startswith("single ") or key in done or t is None:
                continue
            if time.time() - t < RUNNING_S:
                self.running = (key, len(self.cells[key]))
            break

    def behind(self, rev):
        if not self.head or not rev:
            return None
        if rev not in self._behind:
            n = self.git("rev-list", "--count", f"{rev}..HEAD")
            self._behind[rev] = int(n) if n and n.isdigit() else None
        return self._behind[rev]

    def metric(self, r, key):
        if key == "behind":
            return self.behind(r.get("kismet_rev")) if r.get("status") == "built" else None
        return val(r, key)


class Out:
    """Lines of (text, style) segments, drawn with curses or ANSI escapes"""

    def __init__(self, width):
        self.width = width
        self.lines = []

    def add(self, *segs):
        self.lines.append([s if isinstance(s, tuple) else (s, None) for s in segs])


def draw_runs(o, st, mi):
    key, title, fmt = RUN_METRICS[mi]
    o.add((f"Nightly runs: {title}", "head"), ("   r: change", "dim"))

    runs = [r for r in st.runs if val(r, key) is not None]
    if not runs:
        o.add(("  no completed runs logged", "dim"))
        return

    ncols = max(1, (o.width - 10) // 3)
    runs = runs[-ncols:]
    vals = [val(r, key) for r in runs]
    top = max(max(vals), 1)

    for row in range(CHART_H - 1, -1, -1):
        label = fmt(top) if row == CHART_H - 1 else ("0" if row == 0 else "")
        segs = [(f"{label:>8} ", "dim")]
        for r, v in zip(runs, vals):
            units = round(v / top * CHART_H * 8)
            if v > 0:
                units = max(units, 1)
            fill = min(max(units - row * 8, 0), 8)
            bad = r.get("status") != "ok"
            segs.append((VBLOCKS[fill] * 2, "bad" if bad else "bar"))
            segs.append(" ")
        o.add(*segs)

    axis = [" "] * (len(runs) * 3)
    for i in (0, len(runs) - 1) if len(runs) > 2 else range(len(runs)):
        d = day(runs[i].get("ts"))
        p = min(i * 3, len(axis) - len(d))
        if p >= 0 and all(c == " " for c in axis[max(p - 1, 0):p + len(d)]):
            axis[p:p + len(d)] = list(d)
    o.add(" " * 9, ("".join(axis), "dim"))

    last = runs[-1]
    style = "good" if last.get("status") == "ok" else "bad"
    o.add(("  last: ", "dim"), (f"{day(last.get('ts'))} {last.get('status', '?')}", style),
          f"  {hms(val(last, 'duration_s') or 0)}  {val(last, 'built') or 0} built,"
          f" {val(last, 'unchanged') or 0} unchanged, {val(last, 'skipped') or 0} skipped,"
          f" {val(last, 'failed') or 0} failed, publish {last.get('publish', 'not run')}",
          f"  {RUN_METRICS[1][2](val(last, 'energy_j'))}" if val(last, "energy_j") is not None else "")


def draw_current(o, st):
    o.add((f"Newest package per target vs current source {st.head or '?'}", "head"))
    if not st.head:
        o.add((f"  can't read the kismet source in {st.src}", "bad"))

    bar_w = max(8, o.width - NAME_W - 11 - 9 - 30)
    rows = []
    for t in st.names:
        b = st.built.get(t)
        rows.append((t, b, st.behind(b.get("kismet_rev")) if b else None))
    top = max([n for _, _, n in rows if n] or [1])

    for t, b, n in rows:
        segs = [f"  {t:{NAME_W}}"]
        if b is None:
            segs.append(("never built", "bad"))
        else:
            segs.append((f"{b.get('kismet_rev', '?'):10} ", "dim"))
            segs.append((f"{ago(b.get('ts')):>8} ", "dim"))
            if n is None:
                segs.append(("unknown rev", "warn"))
            elif n == 0:
                segs.append(("current", "good"))
            else:
                units = max(round(n / top * bar_w * 8), 1)
                bar = HBLOCKS[8] * (units // 8) + (HBLOCKS[units % 8] if units % 8 else "")
                older = ""
                bt = stamp(b.get("kismet_time"))
                if st.head_time and bt and st.head_time - bt >= 60:
                    older = f", {span(int(st.head_time - bt))} older"
                segs.append((bar, "warn" if n <= 20 else "bad"))
                segs.append(f" {n} behind{older}")

        last = st.latest[t]
        if last is not b and last.get("status") == "failed":
            segs.append((f"  last build failed {ago(last.get('ts'))}", "bad"))
        o.add(*segs)


def draw_history(o, st, mi):
    key, title, fmt = TARGET_METRICS[mi]
    o.add((f"History: {title} per build, oldest to newest", "head"), ("   m: change", "dim"))

    ncols = max(1, (o.width - NAME_W - 2 - 24) // 2)
    cols = st.columns[-ncols:]
    if not cols:
        o.add(("  no target builds logged", "dim"))
        return

    vals = [st.metric(r, key) for c, _ in cols for r in st.cells[c].values()]
    vals = [v for v in vals if v is not None]
    lo, hi = (min(vals), max(vals)) if vals else (0, 0)

    axis = [" "] * (len(cols) * 2)
    for i in range(0, len(cols), 4):
        d = day(cols[i][1])
        if i * 2 + len(d) <= len(axis):
            axis[i * 2:i * 2 + len(d)] = list(d)
    o.add(" " * (NAME_W + 2), ("".join(axis), "dim"))

    for t in st.names:
        segs = [f"  {t:{NAME_W}}"]
        newest = None
        for c, _ in cols:
            r = st.cells[c].get(t)
            if r is None:
                segs.append(("· ", "dim"))
                continue
            s = r.get("status")
            if s == "failed":
                segs.append(("✗ ", "bad"))
                continue
            v = st.metric(r, key)
            if v is None:
                segs.append(("= " if s == "unchanged" else "- ", "dim"))
                continue
            level = 4 if hi == lo else 1 + round((v - lo) / (hi - lo) * 7)
            segs.append((VBLOCKS[level] * 2, "bar"))
            newest = v
        if newest is not None:
            segs.append(f" {fmt(newest)}")
        o.add(*segs)

    if vals:
        o.add(("  " + " " * NAME_W, None), (f"scale {fmt(lo)} {VBLOCKS[1]} to {VBLOCKS[8]} {fmt(hi)}", "dim"),
              ("   ✗ failed  = unchanged  · not built", "dim"))


def render(st, width, rmi, tmi):
    o = Out(width)
    o.add(("Kismet package builds", "head"),
          (f"   source {st.head} {st.head_desc}" if st.head else f"   no kismet source at {st.src}", "dim"))
    if st.error:
        o.add((st.error, "bad"))
    if st.running:
        o.add((f"Building now: {st.running[0]}, {st.running[1]} targets logged so far", "warn"))
    o.add("")
    draw_runs(o, st, rmi)
    o.add("")
    draw_current(o, st)
    o.add("")
    draw_history(o, st, tmi)
    return o


ANSI = {"head": "\033[1m", "dim": "\033[2m", "good": "\033[32m", "warn": "\033[33m",
        "bad": "\033[31m", "bar": "\033[36m"}


def print_once(st):
    color = sys.stdout.isatty()
    width = shutil.get_terminal_size((120, 40)).columns
    for line in render(st, width, 0, 0).lines:
        out = ""
        for text, style in line:
            out += f"{ANSI[style]}{text}\033[0m" if color and style else text
        print(out)


def run_tui(scr, st):
    curses.curs_set(0)
    styles = {"head": curses.A_BOLD, "dim": curses.A_DIM}
    if curses.has_colors():
        curses.use_default_colors()
        for i, (name, c) in enumerate((("good", curses.COLOR_GREEN), ("warn", curses.COLOR_YELLOW),
                                       ("bad", curses.COLOR_RED), ("bar", curses.COLOR_CYAN)), 1):
            curses.init_pair(i, c, -1)
            styles[name] = curses.color_pair(i)

    scr.timeout(60000)
    rmi = tmi = top = 0

    while True:
        h, w = scr.getmaxyx()
        lines = render(st, w, rmi, tmi).lines
        body = h - 1
        top = min(top, max(len(lines) - body, 0))

        scr.erase()
        for y, line in enumerate(lines[top:top + body]):
            x = 0
            for text, style in line:
                if x >= w - 1:
                    break
                try:
                    scr.addnstr(y, x, text, w - 1 - x, styles.get(style, 0))
                except curses.error:
                    pass
                x += len(text)

        help = " m/M history metric  r run metric  arrows scroll  g reload  q quit"
        try:
            scr.addnstr(h - 1, 0, help.ljust(w - 1), w - 1, curses.A_REVERSE)
        except curses.error:
            pass
        scr.refresh()

        k = scr.getch()
        if k in (ord("q"), 27):
            return
        if k == ord("m"):
            tmi = (tmi + 1) % len(TARGET_METRICS)
        elif k == ord("M"):
            tmi = (tmi - 1) % len(TARGET_METRICS)
        elif k == ord("r"):
            rmi = (rmi + 1) % len(RUN_METRICS)
        elif k in (curses.KEY_DOWN, ord("j")):
            top += 1
        elif k in (curses.KEY_UP, ord("k")):
            top = max(top - 1, 0)
        elif k == curses.KEY_NPAGE:
            top += body
        elif k == curses.KEY_PPAGE:
            top = max(top - body, 0)
        elif k in (ord("g"), -1):
            st.load()


def main():
    args = sys.argv[1:]
    once = "--once" in args
    args = [a for a in args if a != "--once"]

    if len(args) not in (2, 3):
        print("Expected [--once] [base] [src] [log]")
        sys.exit(1)

    base, src = args[0], args[1]
    log = args[2] if len(args) == 3 else os.path.join(base, "logs", "builds.log")
    st = Stats(base, src, log)

    if once or not sys.stdout.isatty():
        print_once(st)
    else:
        curses.wrapper(run_tui, st)


if __name__ == "__main__":
    main()
