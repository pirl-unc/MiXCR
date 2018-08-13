#!/usr/bin/env Rscript 

#' to run:
#'   Rscript extract_herv_star_stats.R "input_path" "output_path"
#'   Rscript extract_herv_star_stats.R "/Users/dantebortone/Downloads/studies-tcga-hERV_MiXCR_TRUST-tcga-aa-3681-01a-01r-0905-07-ap1_report.txt" "/Users/dantebortone/Downloads/extracted_mixcr_ap1_stats.csv" "ap1_"
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
  column_tag = "star_"
}

extraction_list = list(
  # Number of input reads |	21652223
  total_reads = c("                          Number of input reads |	", "int"),
  # Average input read length |	76
  ave_read_length = c("                      Average input read length |	", "float"),
  # UNIQUE READS:
  #   Uniquely mapped reads number |	292457
  unique_mapped_reads = c("                   Uniquely mapped reads number |	", "int"),
  #   Uniquely mapped reads % |	1.35%
  unique_mapped_reads_percent = c("                        Uniquely mapped reads % |	", "char"),
  #   Average mapped length |	72.13
  unique_ave_map_length = c("                          Average mapped length |	", "float"),
  #   Number of splices: Total |	11413
  unique_total_splices = c("                       Number of splices: Total |	", "int"),
  #   Number of splices: Annotated (sjdb) |	0
  unique_annotated_slices = c("            Number of splices: Annotated (sjdb) |	", "int"),
  #   Number of splices: GT/AG |	9727
  unique_GT_AG_splices = c("                       Number of splices: GT/AG |	", "int"),
  #   Number of splices: GC/AG |	176
  unique_GC_AG_splices = c("                       Number of splices: GC/AG |	", "int"),
  #   Number of splices: AT/AC |	3
  unique_AT_AC_splices = c("                       Number of splices: AT/AC |	", "int"),
  #   Number of splices: Non-canonical |	1507
  unique_non_canonical_splices = c("               Number of splices: Non-canonical |	", "int"),
  #   Mismatch rate per base, % |	6.35%
  unique_mismatch_rate_per_base = c("                      Mismatch rate per base, % |	", "char"),
  #   Deletion rate per base |	0.07%
  unique_deletion_rate_per_base = c("                         Deletion rate per base |	", "char"),
  #   Deletion average length |	1.83
  unique_ave_deletion_length = c("                        Deletion average length |	", "float"),
  #   Insertion rate per base |	0.07%
  unique_insertion_rate_per_base = c("                        Insertion rate per base |	", "char"),
  #   Insertion average length |	1.53
  unique_ave_insertion_length = c("                       Insertion average length |	", "float"),
  # MULTI-MAPPING READS:
  #   Number of reads mapped to multiple loci |	111284
  multi_mapped_reads = c("        Number of reads mapped to multiple loci |	", "int"),
  # % of reads mapped to multiple loci |	0.51%
  multi_mapped_reads_percent = c("             % of reads mapped to multiple loci |	", "char"),
  #   Number of reads mapped to too many loci |	4429
  uber_multi_mapped_reads = c("        Number of reads mapped to too many loci |	", "int"),
  # % of reads mapped to too many loci |	0.02%
  uber_multi_mapped_reads_percent = c("             % of reads mapped to too many loci |	", "char"),
  # UNMAPPED READS:
  #   % of reads unmapped: too many mismatches |	0.00%
  unmapped_too_many_mismatches = c("       % of reads unmapped: too many mismatches |	", "char"),
  #   % of reads unmapped: too short |	98.11%
  unmapped_too_short = c("                 % of reads unmapped: too short |	", "char"),
  #   % of reads unmapped: other |	0.00%
  unmapped_other = c("                     % of reads unmapped: other |	", "char"),
  # CHIMERIC READS:
  #   Number of chimeric reads |	0
  chimeric_reads = c("                       Number of chimeric reads |	", "int"),
  # % of chimeric reads |	0.00%
  chimeric_read_percent = c("                            % of chimeric reads |	", "char")
)

my_output = unlist(extract_data(extraction_list, input_path, column_tag))

writeLines(my_output, output_path)


