# Concourse Pipeline on BOSH Playground

## What
This project provides the steps, configuration and samples to instantiate a the latest concourse pipeline release, managed by bosh-lite on your local machine using VirtualBox.


## Why
Why use the effort to learn and configure bosh just to run concourse pipeline on virtual box?

Concourse standalone/binary install on Vagrant does not allow the invasion we need for proxy config and such.  So BOSH is the only route to get at the internal config needed.  For those in a corporate environment, slow internet, or other restrictions, a true IaaS may not be readily available, and VB provides means to learn and develop against concourse.


## Prereqs
1. You must have ruby installed (used to install bosh cli gem)
2. You must have VirtualBox 5.x installed with VM extension pack
3. You must have compatible vagrant installed.




## Configure Virtual Box

### Install Virtual Box 5.x
1. Google it.
2. Install Oravle VM Extensions for same version of Virtual Box (available on VB downloads page)

### Create a network
At the time of this writing, the VirtualBox CPI for Bosh-lite create a network names vboxnet1 using IP 192.168.54.1.    You can not use that network for CPI config.  Make sure atleast one other network exists, the IP range should not matter, but our manifest assumes .100.x range.

1. Open VirtualBox
2. Choose VirtualBox > Preferences > Network
3. Create new network named `vboxnet0` .
4. Suggested IP address: `192.168.100.1` 
4. DHCP Server (tab) -> Uncheck Enable Server

If you don';t use the suggested IP, update cloud_cpi_virtualbox.yml network section.
```
networks:
- name: private
  type: manual
  subnets:
  - range: 192.168.100.0/24 # the IP range applicable for virtual box host-only network config
    gateway: 192.168.100.1 # the IP from virtual box host-only network config. 
    az: z1
    cloud_properties:
      name: vboxnet0  # remember, must NOT be one used by vb running bosh-lite
```


## Install & Configure bosh-lite
Nothing special about this step, but requires lots of downloading.

Best to use [bin/bootstrapBoshLite.sh](/bin/bootstrapBoshLite.sh)
```
# install vagrant (google it)
# Grab bosh-lite (google it)

#start BOSH-lite node on virtual box
vagrant up --provider=virtualbox
#upload stemcell
bosh upload stemcell ../releases/bosh-warden-boshlite-ubuntu-trusty-go_agent\?v\=3147 
#upload concourse release tarball
bosh upload release ../releases/concourse-1.3.1.tgz
#upload garden release tarball
bosh upload release ../releases/garden-gun..
#configure bosh release for concourser
# (see concourse docs for AWS, need to use new shared CPI configuration. http://bosh.io/docs/cloud-config.html)
bosh update cloud-config ../samples/bosh/cloud_cpi_virtualbox.yml 
#provide bosh release for concourse against our CPI
bosh deployment ../samples/bosh/bosh_manifest.yml 


bosh deploy 
```


## Add route to local (your actual machine) route table
This will expose our secondary subnet (vboxnet0) to browsers, fly cli, etc.
```
sudo route add -net 192.168.100.0/24 192.168.50.4
```


## Hooray! You're done!

##Extra Credit

### Use browser and fly cli to interacyt with concourse
Create and apply settings to a target (i called it onbosh).  You should visit Concourse excellent tutorials to learn more, beyond the scope of this sample.
```
fly -t onbosh login -c http://192.168.100.11:8080
fly -t onbosh set-pipeline -p hello-world -c samples/pipelines/hello.yml 
fly -t onbosh unpause-pipeline -p hello-world
```

Your first plan should appear in the UI to start building. See [concourse ci tutorials](https://concourse.ci/hello-world.html) for full tutorial using concourse.

### FlightSchool
This is a great tutorial from the concourse team.  It uses a [pre-defined generic pipeline](/samples/pipelines/flightschool.yml) to run the [developer owned task definition](https://github.com/eddiewebb/flight-school/blob/master/build.yml) to execute on every commit!

## Folders
Note: These folders may not exist until you run bin/bootstrap.sh. But keep readin before you do!

- `boshlite` 
    the bosh-lite vagrant image to start a local machine in virtul box or remote in aws. See bosh-lite docs.
- `samples`
    sample manifests and files fro managing the bosh/conousre install
- `releases`
    tarballs and the like required to run bosh/concourse (you will need to download these from bosh.io)


