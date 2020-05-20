FROM adoptopenjdk:11-jre-hotspot

ARG mixcr_version="3.0.13"
ARG imgt_version="202011-3.sv6"

# from https://hub.docker.com/r/milaboratory/mixcr/dockerfile
RUN apt-get update \
    && apt-get install -y unzip \
    && rm -rf /var/lib/apt/lists/* \
    && cd / \
    && curl -s -L -O https://github.com/milaboratory/mixcr/releases/download/v${mixcr_version}/mixcr-${mixcr_version}.zip \
    && unzip mixcr-${mixcr_version}.zip \
    && mv mixcr-${mixcr_version} mixcr \
    && rm mixcr-${mixcr_version}.zip


# Their imgt library was broken and couldn't be unzipped. Replacing that...
RUN \
    apt-get update && \
    apt-get install -yq wget && \
    apt-get clean && \
    cd /mixcr/libraries && \
    wget https://github.com/repseqio/library-imgt/releases/download/v6/imgt.${imgt_version}.json.gz


ENV PATH="/mixcr:${PATH}"
