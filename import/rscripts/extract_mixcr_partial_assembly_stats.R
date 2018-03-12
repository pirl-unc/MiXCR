#!/usr/bin/env Rscript 

#' to run:
#'   Rscript extract_mixcr_align_stats.R "input_path" "output_path"
#'   Rscript extract_mixcr_partial_assembly_stats.R "/Users/dantebortone/Downloads/studies-tcga-hERV_MiXCR_TRUST-tcga-aa-3681-01a-01r-0905-07-ap1_report.txt" "/Users/dantebortone/Downloads/extracted_mixcr_ap1_stats.csv" "ap1_"
#'   
#' scp ~/Desktop/bash_rscript/* dbortone@lbgcluster1.bioinf.unc.edu:/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/RScripts
#' gcloud compute copy-files  /datastore/nextgenout4/share/labs/bioinformatics/seqware/ref/hg19/star_hg19/* @erv-mx-trust-tcga-aa-3681-01a-01r-0905-07:/opt/rscripts


source("/import/rscripts/pipeline_toolkit.R")
#source("pipeline_toolkit.R")

args = commandArgs(trailingOnly=TRUE)
input_path = args[1]
output_path = args[2]
column_tag = args[3]

if(is.na(column_tag)){
  column_tag = "ap_"
}

extraction_list = list(
  total=c("Total alignments analysed: ", "int"),
  num_ouput=c("Number of output alignments: ", "char"),
  have_cdr3=c("Alignments already with CDR3 (no overlapping is performed): ", "char"),
  overlapped=c("Successfully overlapped alignments: ", "char"),
  failed_kmer_extraction=c("Left parts with too small N-region (failed to extract k-mer): ", "char"),
  kmer_diversity=c("Extracted k-mer diversity: ", "int"),
  dropped_for_wildcard=c("Dropped due to wildcard in k-mer: ", "char"),
  dropped_for_short_nregion=c("Dropped due to too short NRegion parts in overlap: ", "char"),
  dropped_for_empty_nregion=c("Dropped overlaps with empty N region due to no complete NDN coverage: ", "char"),
  left_align=c("Number of left-side alignments: ", "char"),
  right_align=c("Number of right-side alignments: ", "char"),
  complex_overlap=c("Complex overlaps: ", "char"),
  over_overlaps=c("Over-overlaps: ", "char"),
  partials_output=c("Partial alignments written to output: ", "char")
)

my_output = unlist(extract_data(extraction_list, input_path, column_tag))

writeLines(my_output, output_path)


