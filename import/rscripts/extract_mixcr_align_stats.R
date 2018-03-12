#!/usr/bin/env Rscript 
# made changes to reflect mixcr2.1.6 output

#' to run:
#'   Rscript extract_mixcr_align_stats.R "input_path" "output_path"
#'   Rscript extract_mixcr_align_stats.R "/Users/dantebortone/Downloads/studies-tcga-hERV_MiXCR_TRUST-tcga-aa-3681-01a-01r-0905-07-tcga-aa-3681-01a-01r-0905-07_alignment_log.txt" "/Users/dantebortone/Downloads/extracted_mixcr_align_stats.csv"
#'   
#' scp ~/Desktop/bash_rscript/* dbortone@lbgcluster1.bioinf.unc.edu:/rstudio-common/ImPro/projects/GCP/hERV_MiXCR_TRUST/RScripts
#' gcloud compute copy-files  /datastore/nextgenout4/share/labs/bioinformatics/seqware/ref/hg19/star_hg19/* @erv-mx-trust-tcga-aa-3681-01a-01r-0905-07:/opt/rscripts


source("/import/rscripts/pipeline_toolkit.R")

args = commandArgs(trailingOnly=TRUE)

input_path = args[1]
output_path = args[2]
column_tag = "align_"

extraction_list = list(
  Total_Reads=c("Total sequencing reads: ", "int"),
  Aligned_Reads=c("Successfully aligned reads: ", "char"),
  Chimeras=c("Chimeras: ", "char"),
  Paired_End_Conflicts_Eliminated=c("Paired-end alignment conflicts eliminated: ", "char"),
  No_TCR_or_Ig=c("Alignment failed, no hits (not TCR/IG?): ", "char"),
  Failed_No_Hits=c("Alignment failed, no hits (not TCR/IG?): ", "char"),
  Failed_No_V_Hits=c("Alignment failed because of absence of V hits: ", "char"),
  Failed_No_J_Hits=c("Alignment failed because of absence of J hits: ", "char"),
  Failed_Poor_Score=c("Alignment failed because of low total score: ", "char"),
  Overlapped=c("Overlapped: ", "char"),
  Overlapped_aligned=c("Overlapped and aligned: ", "char"),
  Alignment_Aided_Overlaps=c("Alignment-aided overlaps: ", "char"),
  Overlapped_Not_Aligned=c("Overlapped and not aligned: ", "char")
)

my_output = unlist(extract_data(extraction_list, input_path, column_tag))

writeLines(my_output, output_path)


