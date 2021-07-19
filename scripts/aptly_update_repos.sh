#!/bin/bash -e

BASE_DIR=${BASE_DIR:-'.'}

for dist in bionic buster bullseye cosmic eoan focal disco kali stretch tara xenial groovy hirsute; do
	( echo "Working on ${dist}"
	rm -rfv ${BASE_DIR}/aptly/${dist}-git-aptly
	rm -rfv ${BASE_DIR}/repos-aptly/apt/git/${dist}

	gpg-connect-agent reloadagent /bye

	aptly --config ${BASE_DIR}/aptly/${dist}-git-aptly.conf repo create ${dist}

	aptly --config ${BASE_DIR}/aptly/${dist}-git-aptly.conf \
		repo add ${dist} ${BASE_DIR}/dpkgs-${dist}/*git*.deb 

	aptly --config ${BASE_DIR}/aptly/${dist}-git-aptly.conf \
		repo add ${dist} ${BASE_DIR}/dpkgs-${dist}/*python3-bluepy*.deb

	aptly --config ${BASE_DIR}/aptly/${dist}-git-aptly.conf \
        -batch \
		-gpg-key=8E18F4B6 \
		-passphrase-file ${BASE_DIR}/../kismet-packages-creds/passphrase \
		-distribution ${dist} \
		-origin Kismet \
		-label Kismet \
		publish repo ${dist} filesystem:git:${dist}
	) &
done

wait

echo "Uploading..."
rsync -av --delete -e "ssh -F ${BASE_DIR}/../kismet-packages-creds/ssh_config -i ${BASE_DIR}/../kismet-packages-creds/id_rsa" ${BASE_DIR}/repos-aptly/apt/git/ dragorn@kismetrepo:repos/apt/git/


exit 1

