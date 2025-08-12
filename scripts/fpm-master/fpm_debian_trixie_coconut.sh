#!/bin/sh

PACKAGE="1.1.0"

${ABI}-strip wifi_coconut

fpm -t deb -a ${ARCH} -s dir -n hak5-wifi-coconut -v ${PACKAGE} \
    --description "Hak5 WiFi Coconut Tools" \
    --depends libusb-1.0-0 \
    ../libwifiuserspace/firmware/rt2870.bin=/usr/share/wifiuserspace/firmware/rt2870.bin \
    ../libwifiuserspace/firmware/LICENSE-ralink-mediatek.txt=/usr/share/wifiuserspace/firmware/LICENSE-ralink-mediatek.txt \
    ./wifi_coconut=/usr/bin/wifi_coconut &

wait

