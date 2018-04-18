# mixcr_2.1.9:2
#   gets the aligned reads using exportReads
#   installs vdjtools

FROM phusion/baseimage:0.9.19

ARG mixcr_version=2.1.9
ARG imgt_version=201802-5.sv2
ARG fastqc_version=0.11.7
ARG vdjtools_version=1.1.7
ARG seqkit_version=0.7.2
ARG pigz_version=2.4

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
  wget https://github.com/milaboratory/mixcr/releases/download/v${mixcr_version}/mixcr-${mixcr_version}.zip && \
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
  Rscript -e 'install.packages("vegan", repos="https://cran.rstudio.com")' && \
  Rscript -e 'install.packages("data.table", repos="https://cran.rstudio.com")'
# parallel is already there and can't be installed like this anyway  
  
# install vdjtools to run diversity metrics 
RUN \
  cd /opt && \
  wget https://github.com/mikessh/vdjtools/releases/download/${vdjtools_version}/vdjtools-${vdjtools_version}.zip && \
  unzip -o vdjtools-*.zip && \
  rm vdjtools-*.zip

# install pigz for seqkit and for decompressing gz files faster.
# RUN \
#  cd /opt && \
#  wget http://zlib.net/pigz/pigz-${pigz_version}.tar.gz && \
#  tar -zxvf pigz*.tar.gz
#rm pigz*.tar.gz
  
# install seqkit to remove fastqs by ids
# RUN \
#  cd /opt && \
#  wget https://github.com/shenwei356/seqkit/releases/download/v${seqkit_version}/seqkit_linux_amd64.tar.gz && \
#  tar -zxvf seqkit*.tar.gz
#rm seqkit*.tar.gz
  
COPY import/ /import/

# install pigz for seqkit and for decompressing gz files faster.
RUN \
  cd /import && \
  tar -zxvf pigz*.tar.gz && \
  rm pigz*.tar.gz && \
  cd pigz* && \
  make && \
  ln -s /import/pigz-${pigz_version}/pigz /usr/local/bin
  
# install seqkit to remove fastqs by ids
RUN \
  cd /import && \
  tar -zxvf seqkit*.tar.gz && \
  rm seqkit*.tar.gz && \
  ln -s /import/seqkit /usr/local/bin
  
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
bash -c 'source /datastore/alldata/shiny-server/rstudio-common/dbortone/docker/mixcr/mixcr_2.1.9/import/run_mixcr.sh \
 --chains "${CHAINS}" \
 --rna_seq "${RNA_SEQ}" \
 --use_existing_vdjca "${USE_EXISTING_VDJCA}" \
 --species "${SPECIES}" \
 --threads "${THREADS}" \
 --r1_path "${INPUT_PATH_1}" \
 --r2_path "${INPUT_PATH_2}" \
 --output_dir "${OUTPUT_DIR}" \
 --sample_name "${SAMPLE_NAME}"'
 