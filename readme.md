# benjaminvincentlab/mixcr

The milaboratory/mixcr:3.0.13-imgt image wasn't working.  There was a problem with the imgt file not 
being able to unzip.

This image builds off of their image (https://hub.docker.com/r/milaboratory/mixcr/dockerfile) and 
then adds a working imgt library.  Additionally, the entrypoint and working directory were removed 
from the Mi Lab version.


## Tagging
v.w.x.y
vwx is the version of MiXCR.  
y is the version of this Dockerfile.  
```bash  
git tag -a 3.0.13.0 -m "Basically Mi Lab image with a working imgt library file."; git push -u origin --tags  
```
