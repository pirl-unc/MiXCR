# mixcr_2.1.9:1
#   upgrades mixcr from 2.1.7 to 2.1.9
#   updates the imgt library to imgt.201802-5.sv2.json.gz
#   drops the seqware user
#   upgrades fastqc from 0.11.5 to 0.11.7 

FROM phusion/baseimage:0.9.19

ARG mixcr_version=2.1.9
ARG imgt_version=201802-5.sv2
ARG fastqc_version=0.11.7

USER root

# install tools
RUN \
  apt-get update && \
  apt-get install -yq \
    default-jdk \
    unzip \
    perl \
    wget && \
  apt-get clean  

# install mixcr
RUN \
  cd /opt && \
  wget https://github.com/milaboratory/mixcr/releases/download/v2.1.9/mixcr-${mixcr_version}.zip && \
  unzip -o mixcr-*.zip && \
  rm mixcr-*.zip && \
  mv /opt/mixcr-${mixcr_version} /opt/mixcr && \
  ln -s /opt/mixcr/mixcr /usr/local/bin

#install IMGT library
RUN \
  cd /opt/mixcr/libraries && \
  wget https://github.com/repseqio/library-imgt/releases/download/v2/imgt.${imgt_version}.json.gz && \
  gunzip imgt.${imgt_version}.json.gz


# Install FastQC
ADD http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${fastqc_version}.zip /tmp/
RUN cd /usr/local && \
    unzip /tmp/fastqc_*.zip && \
    chmod 755 /usr/local/FastQC/fastqc && \
    ln -s /usr/local/FastQC/fastqc /usr/local/bin/fastqc && \
    rm -rf /tmp/fastqc_*.zip

# installing R - to extract diversity measurements and log information when done
RUN \
  apt-get update && \
  apt-get -yq install r-base r-base-dev && \
  apt-get -yq install libatlas3-base && \
  Rscript -e 'install.packages("vegan", repos="https://cran.rstudio.com")'

COPY import/ /import/

RUN apt-get clean



# set environt variables
ENV CHAINS "ALL"

# RNA_SEQ values are true or false
# runs with rna seq parameters if set to true
ENV RNA_SEQ true

# USE_EXISTING_VDJCA values are true or false
# looks for and uses existing VDJCA file if this is set to true
ENV USE_EXISTING_VDJCA false

ENV SPECIES "hsa"
ENV THREADS 1
ENV INPUT_PATH_1 ""
ENV INPUT_PATH_2 ""
ENV OUTPUT_DIR ""
ENV SAMPLE_NAME "no_sample_name_specified"

# once debugged switch to
# bash -c 'source /import/run_mixcr.sh \
# bash -c 'source /datastore/alldata/shiny-server/rstudio-common/dbortone/docker/mixcr/mixcr_2.1.9/import/run_mixcr.sh \

CMD \
bash -c 'source /import/run_mixcr.sh \
 --chains "${CHAINS}" \
 --rna_seq "${RNA_SEQ}" \
 --use_existing_vdjca "${USE_EXISTING_VDJCA}" \
 --species "${SPECIES}" \
 --threads "${THREADS}" \
 --r1_path "${INPUT_PATH_1}" \
 --r2_path "${INPUT_PATH_2}" \
 --output_dir "${OUTPUT_DIR}" \
 --sample_name "${SAMPLE_NAME}"'
 
# need to list out all of the nodes that have docker partitions to make sure that the dokcer image is pushed to all of them
# If you are building an image to a previously existing <sometool>:<version> you need to pull the changes to all of the docker nodes.
# removing the image before rebuilding it isn't enough.
# srun --pty -c 2 --mem 1g -w c6145-docker-2-0.local -p docker bash
# cd /datastore/alldata/shiny-server/rstudio-common/dbortone/docker/mixcr/mixcr_2.1.9
# docker build -t dockerreg.bioinf.unc.edu:5000/mixcr_2.1.9:1 .
# docker push dockerreg.bioinf.unc.edu:5000/mixcr_2.1.9:1
# exit
# srun --pty -c 2 --mem 1g -w fc830-docker-2-0.local -p docker bash
# docker pull dockerreg.bioinf.unc.edu:5000/mixcr_2.1.9:1
# exit
# srun --pty -c 2 --mem 1g -w r820-docker-2-0.local -p docker bash
# docker pull dockerreg.bioinf.unc.edu:5000/mixcr_2.1.9:1
# 
# [dbortone@login2 ~]$ sinfo -p docker
# PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
# docker       up   infinite      1    mix c6145-docker-2-0.local
# docker       up   infinite      2   idle fc830-docker-2-0.local,r820-docker-2-0.local
#
#
