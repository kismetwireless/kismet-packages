#!/bin/sh 

if test "${CHECKOUT}"x = "HEADx"; then
    GITV="HEAD"
    VERSION="git$(date '+%Y-%m-%d')r$(git rev-parse --short ${GITV})-1"
    PACKAGE="9999+${VERSION}"
else
    PACKAGE="${VERSION}"
fi

# Xenial doesn't seem to label strip properly
cp kismet kismet_stripped
strip kismet_stripped

fpm -t deb -a ${ARCH} -s dir -n kismet-core -v ${PACKAGE} \
    --description "Kismet core" \
    --replaces kismet \
    --replaces kismet-plugins \
    --deb-recommends kismet-capture-linux-wifi \
    --deb-recommends kismet-capture-linux-bluetooth \
    --deb-recommends kismet-capture-nrf-mousejack \
    --deb-recommends kismet-capture-ti-cc-2540 \
    --deb-recommends kismet-capture-ti-cc-2531 \
    --deb-recommends kismet-capture-nrf-51822 \
    --deb-recommends kismet-capture-nrf-52840 \
    --deb-recommends kismet-capture-rz-killerbee \
    --deb-recommends kismet-capture-nxp-kw41z \
    --deb-recommends kismet-logtools \
    --deb-recommends kismet-adsb-icao-data \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends zlib1g \
    --depends libpcap0.8 \
    --depends libdw1 \
    --depends libsqlite3-0 \
    --depends libprotobuf9v5 \
    --depends libsensors4 \
    --depends libssl1.0.0 \
    --depends libmosquitto1 \
    ./conf/kismet.conf=/etc/kismet/kismet.conf \
    ./conf/kismet_alerts.conf=/etc/kismet/kismet_alerts.conf \
    ./conf/kismet_httpd.conf=/etc/kismet/kismet_httpd.conf \
    ./conf/kismet_logging.conf=/etc/kismet/kismet_logging.conf \
    ./conf/kismet_memory.conf=/etc/kismet/kismet_memory.conf \
    ./conf/kismet_uav.conf=/etc/kismet/kismet_uav.conf \
    ./conf/kismet_80211.conf=/etc/kismet/kismet_80211.conf \
    ./conf/kismet_filter.conf=/etc/kismet/kismet_filter.conf \
    ./conf/kismet_wardrive.conf=/etc/kismet/kismet_wardrive.conf \
    ./conf/kismet_manuf.txt.gz=/usr/share/kismet/kismet_manuf.txt.gz \
    ./conf/kismet_bluetooth_ids.txt.gz=/usr/share/kismet/kismet_bluetooth_ids.txt.gz \
    ./conf/kismet_bluetooth_manuf.txt.gz=/usr/share/kismet/kismet_bluetooth_manuf.txt.gz \
    ./kismet_stripped=/usr/bin/kismet \
    ./kismet_cap_pcapfile=/usr/bin/kismet_cap_pcapfile \
    ./kismet_cap_kismetdb=/usr/bin/kismet_cap_kismetdb \
    ./packaging/kismet.pc=/usr/share/pkgconfig/kismet.pc \
    ./packaging/systemd/kismet.service=/lib/systemd/system/kismet.service \
    ./http_data/=/usr/share/kismet/httpd &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-linux-wifi -v ${PACKAGE} \
    --description "Kismet Linux Wi-Fi capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --post-install /tmp/fpm/debian/kismet_cap_linux_wifi.postinst \
    --depends libnl-3-200 \
    --depends libnl-genl-3-200 \
    --depends libcap2-bin \
    --depends libcap2 \
    --depends libpcap0.8 \
    --depends libnm0 \
    ./capture_linux_wifi/kismet_cap_linux_wifi=/usr/bin/kismet_cap_linux_wifi &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-linux-bluetooth -v ${PACKAGE} \
    --description "Kismet Linux Bluetooth capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --post-install /tmp/fpm/debian/kismet_cap_linux_bluetooth.postinst \
    --depends libcap2-bin \
    --depends libcap2 \
    --depends libnm0 \
    ./capture_linux_bluetooth/kismet_cap_linux_bluetooth=/usr/bin/kismet_cap_linux_bluetooth &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-nrf-mousejack -v ${PACKAGE} \
    --description "Kismet nRF MouseJack capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    ./capture_nrf_mousejack/kismet_cap_nrf_mousejack=/usr/bin/kismet_cap_nrf_mousejack &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-ti-cc-2540 -v ${PACKAGE} \
    --description "Kismet TICC2540 BTLE Sniffer capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --post-install /tmp/fpm/debian/kismet_cap_ti_cc_2540.postinst \
    --depends libcap2-bin \
    --depends libcap2 \
    --depends libusb-1.0-0 \
    ./packaging/udev/99-kismet-ticc2540.rules=/etc/udev/rules.d/99-kismet-ticc2540.rules \
    ./capture_ti_cc_2540/kismet_cap_ti_cc_2540=/usr/bin/kismet_cap_ti_cc_2540 &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-ti-cc-2531 -v ${PACKAGE} \
    --description "Kismet TICC2531 802.15.4 Zigbee Sniffer capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --post-install /tmp/fpm/debian/kismet_cap_ti_cc_2531.postinst \
    --depends libcap2-bin \
    --depends libcap2 \
    --depends libusb-1.0-0 \
    ./packaging/udev/99-kismet-ticc2531.rules=/etc/udev/rules.d/99-kismet-ticc2531.rules \
    ./capture_ti_cc_2531/kismet_cap_ti_cc_2531=/usr/bin/kismet_cap_ti_cc_2531 &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-rz-killerbee -v ${PACKAGE} \
    --description "Kismet Killerbee Sniffer capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --post-install /tmp/fpm/debian/kismet_cap_rz_killerbee.postinst \
    --depends libcap2-bin \
    --depends libcap2 \
    --depends libusb-1.0-0 \
    ./capture_rz_killerbee/kismet_cap_rz_killerbee=/usr/bin/kismet_cap_rz_killerbee &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-nrf-51822 -v ${PACKAGE} \
    --description "Kismet NRF51822 BTLE Sniffer capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    ./packaging/udev/99-kismet-nrf51822.rules=/etc/udev/rules.d/99-kismet-nrf51822.rules \
    ./capture_nrf_51822/kismet_cap_nrf_51822=/usr/bin/kismet_cap_nrf_51822 &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-nrf-52840 -v ${PACKAGE} \
    --description "Kismet NRF52840 BTLE Sniffer capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    ./packaging/udev/99-kismet-nrf52840.rules=/etc/udev/rules.d/99-kismet-nrf52840.rules \
    ./capture_nrf_52840/kismet_cap_nrf_52840=/usr/bin/kismet_cap_nrf_52840 &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-nxp-kw41z -v ${PACKAGE} \
    --description "Kismet NXP KW41Z BTLE and Zigbee Sniffer capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    ./packaging/udev/99-kismet-nxp-kw41z.rules=/etc/udev/rules.d/99-kismet-nxp-kw41z.rules \
    ./capture_nxp_kw41z/kismet_cap_nxp_kw41z=/usr/bin/kismet_cap_nxp_kw41z &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-serial-radview -v ${PACKAGE} \
    --description "Kismet Radview geiger counter capture helper" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    ./capture_serial_radview/kismet_cap_serial_radview=/usr/bin/kismet_cap_serial_radview &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-radiacode-usb -v ${PACKAGE} \
    --description "Kismet Radiacode USB Geiger counter driver" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    --depends libusb-1.0-0 \
    ./packaging/udev/99-kismet-radiacode-usb.rules=/etc/udev/rules.d/99-kismet-radiacode-usb.rules \
    ./capture_radiacode/kismet_cap_radiacode_usb=/usr/bin/kismet_cap_radiacode_usb &

fpm -t deb -a ${ARCH} -s dir -n kismet-capture-antsdr-droneid -v ${PACKAGE} \
    --description "Kismet AntSDR DJI DroneID driver" \
    --deb-templates /tmp/fpm/debian/kismet.templates \
    --deb-config /tmp/fpm/debian/kismet.config \
    --depends libcap2-bin \
    --depends libcap2 \
    ./capture_antsdr_droneid/kismet_cap_antsdr_droneid=/usr/bin/kismet_cap_antsdr_droneid &

fpm -t deb -a ${ARCH} -s dir -n kismet-logtools -v ${PACKAGE} \
	--description "Kismet kismetdb log tools (kismetdb)" \
	--depends libpcap0.8 \
	--depends libsqlite3-0 \
	./log_tools/kismetdb_strip_packets=/usr/bin/kismetdb_strip_packets \
	./log_tools/kismetdb_to_wiglecsv=/usr/bin/kismetdb_to_wiglecsv \
	./log_tools/kismetdb_statistics=/usr/bin/kismetdb_statistics \
	./log_tools/kismetdb_dump_devices=/usr/bin/kismetdb_dump_devices \
    ./log_tools/kismetdb_to_gpx=/usr/bin/kismetdb_to_gpx \
    ./log_tools/kismetdb_clean=/usr/bin/kismetdb_clean \
    ./log_tools/kismetdb_to_kml=/usr/bin/kismetdb_to_kml \
    ./log_tools/kismetdb_to_pcap=/usr/bin/kismetdb_to_pcap &

fpm -t deb -a ${ARCH} -s dir -n kismet-adsb-icao-data -v ${PACKAGE} \
    --description "Kismet ADSB ICAO data" \
    ./conf/kismet_adsb_icao.txt.gz=/usr/share/kismet/kismet_adsb_icao.txt.gz &

fpm -t deb -a ${ARCH} -s empty -n kismet -v ${PACKAGE} \
    --description "Kismet metapackage" \
    --depends kismet-core \
    --depends kismet-adsb-icao-data \
    --depends kismet-capture-linux-wifi \
    --depends kismet-capture-linux-wifi \
    --depends kismet-capture-linux-bluetooth \
    --depends kismet-capture-nrf-mousejack \
    --depends kismet-capture-ti-cc-2531 \
    --depends kismet-capture-nrf-51822 \
    --depends kismet-capture-nxp-kw41z \
    --depends kismet-capture-nrf-52840 \
    --depends kismet-capture-rz-killerbee \
    --depends kismet-capture-serial-radview \
    --depends kismet-capture-radiacode-usb \
    --depends kismet-capture-antsdr-droneid \
    --depends kismet-logtools &

wait


