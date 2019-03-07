#!/usr/bin/env Rscript 
# made changes to reflect mixcr2.1.6 output

#' to run:
#'   Rscript extract_mixcr_align_stats.R "input_path" "output_path"
#'   Rscript extract_mixcr_partial_assembly_stats.R "/Users/dantebortone/Downloads/studies-tcga-hERV_MiXCR_TRUST-tcga-aa-3681-01a-01r-0905-07-ap1_report.txt" "/Users/dantebortone/Downloads/extracted_mixcr_ap1_stats.csv" "ap1_"
#'   
#' scp ~/Desktop/bash_rscript/* dbortone@lbgcluster1.bioinf.unc.edu:/datastore/alldata/shiny-server/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/RScripts/
#' gcloud compute copy-files /datastore/alldata/shiny-server/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/RScripts/* @erv-mx-trust-tcga-aa-3681-01a-01r-0905-07:/opt/rscripts/
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
  column_tag = "cl_"
}

extraction_list = list(
  Clonotype_Count = c("Final clonotype count: ", "int"),
  Ave_Reads = c("Average number of reads per clonotype: ", "float"),
  Reads_Used = c("Reads used in clonotypes, percent of total: ", "char"),
  Reads_Used_Before_Clustering = c("Reads used in clonotypes before clustering, percent of total: ", "char"),
  Reads_Used_As_Core = c("Number of reads used as a core, percent of used: ", "char"),
  Mapped_Low_Quality_Reads = c("Mapped low quality reads, percent of used: ", "char"),
  Reads_Clustered_w_PCR_Error_Correction = c("Reads clustered in PCR error correction, percent of used: ", "char"),
  Reads_Preclustered = c("Reads pre-clustered due to the similar VJC-lists, percent of used: ", "char"),
  Reads_Dropped_No_CDR3 = c("Reads dropped due to the lack of a clone sequence: ", "char"),
  Reads_Dropped_Low_Quality = c("Reads dropped due to low quality: ", "char"),
  Reads_Dropped_Failed_Mapping = c("Reads dropped due to failed mapping: ", "char"),
  Reads_Dropped_Low_Quality_Clones = c("Reads dropped with low quality clones: ", "char"),
  Clones_Dropped_By_PCR_Error_Correction = c("Clonotypes eliminated by PCR error correction: ", "int"),
  Clone_Dropped_Low_Quality = c("Clonotypes dropped as low quality: ", "int"),
  Clones_Preclustered = c("Clonotypes pre-clustered due to the similar VJC-lists: ", "int")
)

my_output = unlist(extract_data(extraction_list, input_path, column_tag))

writeLines(my_output, output_path)


