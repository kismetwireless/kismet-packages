#!/bin/bash 

if test $# -ne 2; then
    echo "Expected [basedir] [version]"
    exit
fi

export BASE_DIR=$1

export gpg_tty=$(tty)

export RELEASEMATCH=$2

for dist in kali bionic bullseye bookworm disco jammy kinetic lunar mantic; do
    ( 
        cd ${BASE_DIR}
        echo "Working on ${dist}"
        rm -rfv ${BASE_DIR}/aptly/${dist}-release-aptly
        rm -rfv ${BASE_DIR}/repos-aptly/apt/release/${dist}

        aptly --config ${BASE_DIR}/aptly/${dist}-release-aptly.conf repo create ${dist}

        aptly --config ${BASE_DIR}/aptly/${dist}-release-aptly.conf \
            repo add ${dist} ${BASE_DIR}/dpkgs-${dist}/*$RELEASEMATCH*.deb 

        aptly --config ${BASE_DIR}/aptly/${dist}-release-aptly.conf \
            repo add ${dist} ${BASE_DIR}/dpkgs-${dist}/*python3-bluepy\*.deb

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


