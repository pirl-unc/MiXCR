# mixcr_2.1.9:3
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

COPY import/ /import/

# install pigz for seqkit and for decompressing gz files faster.
RUN \
  cd /import && \
  tar -zxvf pigz*.tar.gz && \
  rm pigz*.tar.gz && \
  cd pigz* && \
  make && \
  ln -s /import/pigz-${pigz_version}/pigz /usr/local/bin
  
RUN apt-get clean



# set environt variables
ENV CHAINS "ALL"

# RNA_SEQ values are true or false
# runs with rna seq parameters if set to true
# will convert text of this value to lowercaase
ENV RNA_SEQ true

# USE_EXISTING_VDJCA values are true or false
# looks for and uses existing VDJCA file if this is set to true
# will convert text of this value to lowercase
ENV USE_EXISTING_VDJCA false

ENV SPECIES "hsa"
ENV THREADS 1
ENV INPUT_PATH_1 ""
ENV INPUT_PATH_2 ""
ENV OUTPUT_DIR ""
ENV SAMPLE_NAME "no_sample_name_specified"
ENV IMPORT_DIR "/import"

#  DEBUG_MODE:true  will pull the sh script from the cluster version of the code rather than the locally stored one.
#    This allows changes to be made and have them go into effect instantly, without needing to rebuild the docker image
#    and push/pull the changes.  When done with debugging the changes should be push/pulled to all the nodes so the changes.
#    go into effect and are kept in the image rather than locally.
ENV DEBUG_MODE false

# SEPARATE_BY_C true will seperate clones by their isotype.  default is set to false.
ENV SEPARATE_BY_C false

CMD \
  if [ ${DEBUG_MODE} = "true" ] ; \
    then \
      IMPORT_DIR="/datastore/alldata/shiny-server/rstudio-common/dbortone/docker/mixcr/mixcr_2.1.9/import"; \
      echo "DEBUG MODE: Local sh file will be used instead of local docker container script."; \
  else \
    echo "Debug mode is off."; \
  fi && \
  bash -c "source ${IMPORT_DIR}/run_mixcr.sh \
    --import_dir ${IMPORT_DIR} \
    --chains ${CHAINS} \
    --rna_seq ${RNA_SEQ} \
    --use_existing_vdjca ${USE_EXISTING_VDJCA} \
    --species ${SPECIES} \
    --threads ${THREADS} \
    --r1_path ${INPUT_PATH_1} \
    --r2_path ${INPUT_PATH_2} \
    --output_dir ${OUTPUT_DIR} \
    --sample_name ${SAMPLE_NAME} \
    --separate_by_c ${SEPARATE_BY_C}"
 