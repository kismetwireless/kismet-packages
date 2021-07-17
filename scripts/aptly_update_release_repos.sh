#!/bin/bash -e

if test $# -ne 1; then
    echo "Expected [version]"
    exit
fi

BASE_DIR=${BASE_DIR:-'.'}

export GPG_TTY=$(tty)

RELEASEMATCH=$1

for dist in bionic buster bullseye cosmic disco focal eoan groovy hirsute kali stretch tara xenial; do
	( echo "Working on ${dist}"
	rm -rfv ${BASE_DIR}/aptly/${dist}-release-aptly
	rm -rfv ${BASE_DIR}/repos-aptly/apt/release/${dist}

	aptly --config ${BASE_DIR}/aptly/${dist}-release-aptly.conf repo create ${dist}

	aptly --config ${BASE_DIR}/aptly/${dist}-release-aptly.conf \
		repo add ${dist} ${BASE_DIR}/dpkgs-${dist}/*$RELEASEMATCH*.deb

	aptly --config ${BASE_DIR}/aptly/${dist}-release-aptly.conf \
        -batch \
		-gpg-key 8E18F4B6 \
		-passphrase-file ${BASE_DIR}/../kismet-packages-creds/passphrase \
		-distribution ${dist} \
		-origin Kismet \
		-label Kismet \
		publish repo ${dist} filesystem:release:${dist}
	) &
done

wait

echo "Uploading..."
rsync -av --delete -e "ssh -F ${BASE_DIR}/../kismet-packages-creds/ssh_config -i ${BASE_DIR}/../kismet-packages-creds/id_rsa" ${BASE_DIR}/repos-aptly/apt/release/ dragorn@kismetrepo:repos/apt/release/


exit 1


