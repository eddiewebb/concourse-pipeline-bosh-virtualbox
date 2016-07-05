set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}/../boshlite
vagrant up --provider=virtualbox
bosh upload stemcell ../releases/bosh-warden-boshlite-ubuntu-trusty-go_agent\?v\=3147 
bosh upload release ../releases/concourse-1.3.1.tgz 
bosh upload release ../releases/garden-runc-0.3.0.tgz 
bosh update cloud-config ../samples/bosh/cloud_cpi_virtualbox.yml 
bosh deployment ../samples/bosh/bosh_manifest.yml 
bosh deploy
set +e