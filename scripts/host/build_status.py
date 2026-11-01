#!/usr/bin/env python3

# Summarize logs/builds.log (see buildlog): the last run, the newest build of
# each target and how far behind the kismet source it is, where the build time
# goes, and what each build picked up from git.
#
# Usage: build_status.py [base] [src] [log]
#   base    kismet-packages directory
#   src     kismet source tree the builds use
#   log     build log to read (default [base]/logs/builds.log)

import re
import subprocess
import sys

FIELD = re.compile(r'([A-Za-z0-9_]+)=("(?:[^"\\]|\\.)*"|\S*)')


def parse(line):
    rec = {}
    for k, v in FIELD.findall(line):
        if v.startswith('"'):
            v = re.sub(r'\\(.)', r'\1', v[1:-1])
        rec[k] = v
    return rec


def num(r, k):
    try:
        return int(r.get(k, 0))
    except ValueError:
        return 0


def hms(s):
    return f"{s // 3600}:{s % 3600 // 60:02d}:{s % 60:02d}"


def git(src, *args):
    try:
        return subprocess.run(["git", "-C", src, *args], capture_output=True, text=True).stdout.strip()
    except OSError:
        return ""


if len(sys.argv) not in (3, 4):
    print("Expected [base] [src] [log]")
    sys.exit(1)

base, src = sys.argv[1], sys.argv[2]
log = sys.argv[3] if len(sys.argv) == 4 else f"{base}/logs/builds.log"

try:
    with open(log) as f:
        recs = [parse(l) for l in f if l.strip()]
except OSError as e:
    print(f"Can't read {log}: {e.strerror}")
    sys.exit(1)

targets = [r for r in recs if r.get("type") == "target" and r.get("target")]
runs = [r for r in recs if r.get("type") == "run"]
head = git(src, "rev-parse", "--short", "HEAD")

if head:
    print(f"kismet source is at {head}: {git(src, 'log', '-1', '--format=%s (%cr)')}")
    print()

if runs:
    r = runs[-1]
    print(f"Last run {r.get('run', '?')} ({r.get('ts', '?')}): {r.get('status', '?')}, {hms(num(r, 'duration_s'))}, "
          f"{num(r, 'built')} built / {num(r, 'unchanged')} unchanged / {num(r, 'skipped')} skipped / "
          f"{num(r, 'failed')} failed, publish {r.get('publish', 'not run')}, CPU energy {r.get('energy_j', 'na')} J")
    print()

if not targets:
    print("No target builds logged")
    sys.exit(0)

latest = {}
built = {}
for r in targets:
    latest[r["target"]] = r
    if r.get("status") == "built":
        built[r["target"]] = r

print(f"{'TARGET':24} {'STATUS':9} {'LAST BUILT':10} {'BEHIND':>6} {'TIME':>8} {'CPU':>8} {'PEAK MB':>7} "
      f"{'WARN':>5} {'DEBS':>4} {'SIZE MB':>7} {'ENERGY J':>8}")
for t, r in sorted(latest.items()):
    b = built.get(t)
    if b is None:
        print(f"{t:24} {r.get('status', '?'):9} {'never':10} {'-':>6} {'-':>8} {'-':>8} {'-':>7} "
              f"{'-':>5} {'-':>4} {'-':>7} {'-':>8}")
        continue
    rev = b.get("kismet_rev", "?")
    behind = git(src, "rev-list", "--count", f"{rev}..{head}") if head else ""
    print(f"{t:24} {r.get('status', '?'):9} {rev:10} {behind or '?':>6} {hms(num(b, 'duration_s')):>8} "
          f"{hms(num(b, 'cpu_s')):>8} {b.get('mem_peak_mb', '-'):>7} {b.get('warnings', '-'):>5} "
          f"{b.get('debs', '-'):>4} {num(b, 'deb_kb') // 1024:>7} {b.get('energy_j', 'na'):>8}")

print()
print("Where the time goes in the last build (seconds):")
print(f"{'TARGET':24} {'REGEN':>5} {'CLONE':>5} {'CONFIG':>6} {'MAKE':>5} {'PACKAGE':>7} {'OTHER':>5} {'CPU/WALL':>8}")
for t, b in sorted(built.items()):
    parts = [num(b, k) for k in ("regen_s", "clone_s", "configure_s", "make_s", "package_s")]
    total = num(b, "duration_s")
    par = num(b, "cpu_s") / total if total else 0
    print(f"{t:24} {parts[0]:>5} {parts[1]:>5} {parts[2]:>6} {parts[3]:>5} {parts[4]:>7} "
          f"{max(total - sum(parts), 0):>5} {par:>7.1f}x")

print()
print("What the last build picked up from git:")
for t, b in sorted(built.items()):
    if b.get("prev_rev"):
        print(f"  {t}: {b['prev_rev']}..{b.get('kismet_rev', '?')}  {b.get('commits', '?')} commits, "
              f"{b.get('files_changed', '?')} files, +{b.get('insertions', '?')} -{b.get('deletions', '?')}")
    else:
        print(f"  {t}: first logged build, {b.get('kismet_rev', '?')}")

failed = [r for t, r in sorted(latest.items()) if r.get("status") == "failed"]
if failed:
    print()
    print("Failing targets:")
    for r in failed:
        print(f"  {r['target']} ({r.get('ts', '?')}): {r.get('reason') or 'no recognized error'}")
        if r.get("failed_packages"):
            print(f"      packages: {r['failed_packages']}")
