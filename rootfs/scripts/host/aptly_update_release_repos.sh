#!/bin/bash 

if test $# -ne 1; then
    echo "Expected [version]"
    exit
fi

BASE_DIR=${BASE_DIR:-'.'}

export gpg_tty=$(tty)

RELEASEMATCH=$1

for dist in kali bionic buster bullseye cosmic disco focal eoan groovy hirsute impish kali xenial; do
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


