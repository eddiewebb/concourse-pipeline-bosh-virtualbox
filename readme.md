# Concourse CI Playground

## Starting
Concourse will load at 192.168.100.5:8080.  You will need to disable all outbound procxy for browser (easiest to use firefox and disable within that browser vs, system wide setting.)

1) Follow Concourse CI Tutorial dfor setting up vagrant with virtual box.
 1) THis sample Vagrantfile is pre-configuyred with proxy to point to local CNTLM
 2) Follow http://www.laurivan.com/set-up-concourse-behind-a-proxy/ to install vagrant-proxy, and if needed alter the proxy URL.


## Sample Pipelines
You can find pipelines in samples/pipelines folder

```
#connect to local Concourse container, give it nickname "lite" to target in future tasks
fly -t lite login -c http://192.168.100.4:8080   
# configure a pipeline by providing a manifest
fly -t lite set-pipeline -p hello-world -c samples/hello/hello.yml 
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