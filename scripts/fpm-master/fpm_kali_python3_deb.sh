#!/bin/sh

if test "${CHECKOUT}"x = "HEADx"; then
    GITV="HEAD"
    VERSION="git$(date '+%Y-%m-%d')r$(git rev-parse --short ${GITV})-1"
    PACKAGE="9999+${VERSION}"
else
    PACKAGE="${VERSION}"
fi

fpm -t deb -s python --python-bin python3 --python-pip pip3 --python-install-bin /usr/bin/ -v ${PACKAGE} \
    --replaces python-kismetcapturertl433 \
    --depends python3 \
    --depends python3-protobuf \
    --depends python3-usb \
    --depends python3-websockets \
    --depends 'librtlsdr0 | librtlsdr2' \
    --depends rtl-433 \
    --python-package-name-prefix python3 \
    --python-setup-py-arguments '--prefix=/usr' \
    --python-install-lib /usr/lib/python3/dist-packages \
    ./capture_sdr_rtl433 &
 
fpm -t deb -s python --python-bin python3 --python-pip pip3 --python-install-bin /usr/bin/ -v ${PACKAGE} \
    --replaces python-kismetcapturertlamr \
    --depends python3 \
    --depends python3-protobuf \
    --depends python3-usb \
    --depends python3-websockets \
    --depends 'librtlsdr0 | librtlsdr2' \
    --python-package-name-prefix python3 \
    --python-setup-py-arguments '--prefix=/usr' \
    --python-install-lib /usr/lib/python3/dist-packages \
    ./capture_sdr_rtlamr &

fpm -t deb -s python --python-bin python3 --python-pip pip3 --python-install-bin /usr/bin/ -v ${PACKAGE} \
    --replaces python-kismetcapturertladsb \
    --depends python3 \
    --depends python3-protobuf \
    --depends python3-usb \
    --depends python3-numpy \
    --depends python3-websockets \
    --depends 'librtlsdr0 | librtlsdr2' \
    --python-package-name-prefix python3 \
    --python-setup-py-arguments '--prefix=/usr' \
    --python-install-lib /usr/lib/python3/dist-packages \
    ./capture_sdr_rtladsb &

fpm -t deb -s python --python-bin python3 --python-pip pip3 --python-install-bin /usr/bin/ -v ${PACKAGE} \
    --replaces python-kismetcapturefreaklabszigbee \
    --depends python3 \
    --depends python3-protobuf \
    --depends python3-usb \
    --depends python3-serial \
    --python-package-name-prefix python3 \
    --python-setup-py-arguments '--prefix=/usr' \
    --python-install-lib /usr/lib/python3/dist-packages \
    --python-disable-dependency pyserial \
    ./capture_freaklabs_zigbee &

# # Generate package from public bluepy; something is broken on at least ubuntu-hirsute so
# # we need to jump through some hoops to do some of it manually; maybe the new pip doesn't
# # play nice with fpm?
# ( 
#     pip3 download \
#         --no-clean \
#         --no-deps \
#         --no-binary \
#         :all: \
#         -i https://pypi.python.org/simple \
#         -d /tmp \
#         bluepy==1.3.0
# 
#     tar xf /tmp/bluepy-1.3.0.tar.gz --directory=/tmp
# 
#     fpm -t deb -s python --python-bin python3 --python-pip pip3 -v 1.3.0 \
#         --depends python3 \
#         --python-package-name-prefix python3 \
#         --python-setup-py-arguments '--prefix=/usr' \
#         --python-install-lib /usr/lib/python3/dist-packages \
#         /tmp/bluepy-1.3.0
# ) &
# 
# fpm -t deb -s python --python-bin python3 --python-pip pip3 --python-install-bin /usr/bin/ -v ${PACKAGE} \
#     --replaces python-kismetcapturebtgeiger \
#     --depends python3 \
#     --depends python3-protobuf \
#     --depends python3-websockets \
#     --python-package-name-prefix python3 \
#     --python-setup-py-arguments '--prefix=/usr' \
#     --python-install-lib /usr/lib/python3/dist-packages \
#     ./capture_bt_geiger &

wait

