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




## Setting up Bosh for concousr
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

```


## Sample Pipelines
You can find pipelines in samples/pipelines folder

```
#connect to local Concourse container, give it nickname "lite" to target in future tasks
fly -t lite login -c http://192.168.100.4:8080   
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

