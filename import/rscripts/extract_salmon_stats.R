#!/usr/bin/env Rscript 

#' to run:
#'   Rscript extract_salmon_stats.R "input_path" "output_path"
#'   Rscript extract_salmon_stats.R "/Users/dantebortone/Downloads/studies-tcga-hERV_MiXCR_TRUST-tcga-aa-3681-01a-01r-0905-07-ap1_report.txt" "/Users/dantebortone/Downloads/extracted_mixcr_ap1_stats.csv" "ap1_"
#'   
#' scp ~/Desktop/bash_rscript/* dbortone@lbgcluster1.bioinf.unc.edu:/datastore/alldata/shiny-server/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/RScripts/
#' gcloud compute copy-files /datastore/alldata/shiny-server/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/rscripts/* @erv-mx-trust-tcga-aa-3681-01a-01r-0905-07:/opt/rscripts/
#' 
#' 
#' To make a new verion of this for another module all you really need to change is the cloumn_tag and the extraction_list


source("/import/rscripts/pipeline_toolkit.R")
#source("pipeline_toolkit.R")

args = commandArgs(trailingOnly=TRUE)
input_path = args[1]
output_path = args[2]
column_tag = args[3]

if(is.na(column_tag)){
  column_tag = "salmon_"
}

extraction_list = list(
  #Total # of mapped reads : 403741
  total_mapped_reads = c("Total # of mapped reads : ", "int"),
  # of uniquely mapped reads : 297657
  uniquely_mapped_reads = c("# of uniquely mapped reads : ", "int"),
  # ambiguously mapped reads : 106084
  ambiguously_mapped_reads = c("# ambiguously mapped reads : ", "int")
)

my_output = unlist(extract_data(extraction_list, input_path, column_tag))

writeLines(my_output, output_path)


