#!/bin/bash

# Make sure user has vragant and virtualbox, we cant script that..
echo "Have you installed Vagrant and Virtual box?  (y/N)"

read answer

if [ "$answer" == "y" -o "$answer" == "Y" ]; then
	echo "Great, creating boshlite director..."
else
	printf "\n\n\t[[[ Sorry! ]]]\nYou will need to install Virtual Box 5.x and compatible vagrant before going forward\n\n" >&2
	exit 1
fi



function downloadIfNeeded {
	path=$2
	url=$1
	expectedhash=$3
	echo "Downloading $url if not present"
	if [ -f $path ]; then
		printf "\tcalculating local hash\n"
		md5hash=`md5 -q $path`
		if [ "$md5hash" == "$expectedhash" ];then
			printf "\t${path} exists with valid checksum, skipping download\n\n"
			return
		else
			printf "Release path found, but does not match expected checksum, re-downloading.\n"
		fi
	else
		printf "\tRelease not found, downloading..\n"
	fi
	curl -L $url > $path
	printf "done\n\n"
}








set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#clone/install bosh-lite imahge into new folder 
echo Grabbing latest bosh-lite from github
[ -d boshlite ] || git clone https://github.com/cloudfoundry/bosh-lite boshlite 1>/dev/null
echo done

#install bosh cli (ruby gem)
echo "Installing bosh cli if not present(a ruby gem)"
gem install bosh_cli --no-ri --no-rdoc 1>/dev/null
echo done

#download releases & stemcell
[ -d ${DIR}/../releases ] || mkdir ${DIR}/../releases
cd ${DIR}/../releases
downloadIfNeeded https://s3.amazonaws.com/bosh-warden-stemcells/bosh-stemcell-3147-warden-boshlite-ubuntu-trusty-go_agent.tgz bosh-warden-boshlite-ubuntu-trusty-go_agent f2bf03c0cc30a2c7fda1464116ba9efd
downloadIfNeeded https://github.com/concourse/concourse/releases/download/v1.3.1/concourse-1.3.1.tgz concourse-1.3.1.tgz c6fcf09a1654ec3bf1ba4864fff51490
downloadIfNeeded https://github.com/concourse/concourse/releases/download/v1.3.1/garden-runc-0.3.0.tgz garden-runc-0.3.0.tgz 8939b7d39ab126b8ed61c241c752992a
echo downloads complete

#instantiate boshlite and rpvide artifacts
echo "attempting to start bosh-lite director"
cd ${DIR}/../boshlite
vagrant up --provider=virtualbox
echo done

echo "Attempting to seed bosh with concourse release and deploy!"
bosh upload stemcell ../releases/bosh-warden-boshlite-ubuntu-trusty-go_agent
bosh upload release ../releases/concourse-1.3.1.tgz 
bosh upload release ../releases/garden-runc-0.3.0.tgz 
bosh update cloud-config ../samples/bosh/cloud_cpi_virtualbox.yml 
bosh deployment ../samples/bosh/bosh_manifest.yml 
bosh deploy


printf "\n\n Hard part is complete!\n\t You will need to install the fly CLI to interact with concourse further\n"
set +e