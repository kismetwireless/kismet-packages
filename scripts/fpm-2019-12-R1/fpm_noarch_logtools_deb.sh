#!/bin/sh -ex

if test "${CHECKOUT}"x = "HEADx"; then
    GITV="HEAD"
    VERSION="git$(date '+%Y-%m-%d')r$(git rev-parse --short ${GITV})-1"
    PACKAGE="9999+${VERSION}"
else
    PACKAGE="${VERSION}"
fi

sudo fpm -t deb -s dir -n python-kismet-logtool-kml -v ${PACKAGE} \
	--description "KismetDB to KML conversion tool (python based)" \
	--architecture all \
	--depends python \
	--depends python-dateutil \
	--depends python-pip \
	./log_tools/kismet_log_to_kml.py=/usr/bin/kismet_log_to_kml &

sudo fpm -t deb -s dir -n python-kismet-logtool-csv -v ${PACKAGE} \
	--description "KismetDB to CSV conversion tool (python based)" \
	--architecture all \
	--depends python \
	--depends python-dateutil \
	--depends python-pip \
	./log_tools/kismet_log_to_csv.py=/usr/bin/kismet_log_to_csv &

sudo fpm -t deb -s dir -n python-kismet-logtool-pcap -v ${PACKAGE} \
	--description "KismetDB to PCAP conversion tool (python based)" \
	--architecture all \
	--depends python \
	--depends python-dateutil \
	--depends python-pip \
	./log_tools/kismet_log_to_pcap.py=/usr/bin/kismet_log_to_pcap &

sudo fpm -t deb -s empty -n python-kismet-logtools -v ${PACKAGE} \
	--description "Kismet log tools metapackage" \
	--architecture all \
	--depends python-kismet-logtool-kml \
	--depends python-kismet-logtool-csv \
	--depends python-kismet-logtool-pcap &

wait


