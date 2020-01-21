#!/usr/bin/env Rscript 

#' to run:
#'   Rscript extract_mixcr_extension_stats.R "input_path" "output_path"
#'   Rscript extract_mixcr_extension_stats.R "/Users/dantebortone/Downloads/studies-tcga-hERV_MiXCR_TRUST-tcga-aa-3681-01a-01r-0905-07-extension_report.txt" "/Users/dantebortone/Downloads/extracted_mixcr_extension_stats.csv"
#'   
#' scp ~/Desktop/bash_rscript/* dbortone@lbgcluster1.bioinf.unc.edu:/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/RScripts
#' gcloud compute copy-files  /datastore/nextgenout4/share/labs/bioinformatics/seqware/ref/hg19/star_hg19/* @erv-mx-trust-tcga-aa-3681-01a-01r-0905-07:/opt/rscripts


source("/import/rscripts/pipeline_toolkit.R")

args = commandArgs(trailingOnly=TRUE)
input_path = args[1]
output_path = args[2]
column_tag = "ex_"

extraction_list = list(
  extended_alignments = c("Extended alignments count: ", "char"),
  v_extensions = c("V extensions total: ", "char"),
  v_extensions_w_targets = c("V extensions with merged targets: ", "char"),
  j_extensions = c("J extensions total: ", "char"),
  j_extensions_w_targets = c("J extensions with merged targets: ", "char"),
  vj_extensions = c("V+J extensions: ", "char"),
  v_length = c("Mean V extension length: ", "float"),
  j_length = c("Mean J extension length: ", "float")
)

my_output = unlist(extract_data(extraction_list, input_path, column_tag))

writeLines(my_output, output_path)


