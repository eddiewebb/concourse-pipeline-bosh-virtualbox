# Concourse CI Playground

## Folders
- boshlite
  the bosh-lite vagrant image to start a local machine in virtul box or remote in aws. See bosh-lite docs.
- samples
  sample manifests and files fro managing the bosh/conousre install
- releases
  tarballs and the like required to run bosh/concourse

## Starting
COncourse on Vagrant does not allow the invasion we need for proxy config and such.  So BOSH is the only route.




## Setting up Bosh for concourse
See bin/bootstrapBoshLite.sh for latest
```
# install vagrant
# Grab bosh-lite (google)

#start BOSH-lite node in AWS
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



# UNverified WIP
I am converting from concourse standalone to a bosh-lite deploy using vagrant and virtual box. Instructions below may not refelct that.

# Using Virtual Box with Host-Only Netwrk (no internet)
## Determine unused subnet on virtual box
at the time of this writing, the VirtualBox CPI for Bosh-lite create a network names vboxnet1 using IP 192.168.54.1.    You can not use that network for CPI config.  Make sure atleast one other network exists in Preferences > Networks > Host Only (tab).   Grab the IP from that edit dialog.

```

networks:
- name: private
  type: manual
  subnets:
  - range: 192.168.100.0/24
    gateway: 192.168.100.1 # the IP from virtual box host-only network config. 
   .
    az: z1
    cloud_properties:
      name: vboxnet0  # remember, its NOT the one used by vb running bosh-lite
```












## Sample Pipelines
You can find pipelines in samples/pipelines folder

```
#connect to local Concourse container, give it nickname "lite" to target in future tasks
fly -t lite login -c http://10.0.2.11:8080   
# configure a pipeline by providing a manifest
fly -t lite set-pipeline -p hello-world -c samples/hello/hello.yml 
y
# unpause pipeline
fly -t lite unpause-pipeline -p hello-world
# now play in the UI 
```


Watching/Hijacking
You can watch a build, or hijack the container it runs in.
```
fly -t lite hijack --job hello-world/hello-world #steals the container, kills runnning job
fly -t lite watch --job hello-world/hello-world #monitors running job
```



# getting docker to work on proxy
set /etc/default/docker http://stackoverflow.com/questions/26679212/why-can-i-not-resolve-docker-io-and-other-hosts-behind-proxy-from-within-vagrant


https://concourseci.slack.com/archives/general/p1465917989000287 
"seem to have resolved it by also setting http_proxy properties on the garden job"


https://concourseci.slack.com/archives/general/p1467131891003294

