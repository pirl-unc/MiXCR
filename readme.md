# benjaminvincentlab/mixcr

The milaboratory/mixcr:3.0.13-imgt image wasn't working.  There was a problem with the imgt file not 
being able to unzip.

This image builds off of their image (https://hub.docker.com/r/milaboratory/mixcr/dockerfile) and 
then adds a working imgt library.  Additionally, the entrypoint and working directory were removed 
from the Mi Lab version.