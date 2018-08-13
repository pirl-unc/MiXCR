#!/usr/bin/env Rscript 

source("/import/rscripts/pipeline_toolkit.R")
library(vegan)

args = commandArgs(trailingOnly=TRUE)
sample_id = args[1]
input_path = args[2]
output_path = args[3]

# input_path = "studies-tcga-hERV_MiXCR_TRUST-tcga-b8-4146-01b-11r-1672-07-tcga-b8-4146-01b-11r-1672-07_assembled_clones.txt"
# output_path = "MiXCR_stats.csv"

#print(paste0("input_path:", input_path))
#print(paste0("output_path:", output_path))

clone_df = read.delim(input_path)

chains = c("IGH", "IGL", "IGK", "TRA", "TRB", "TRG", "TRD")

chain_summary = summary(factor(clone_df$Chains))
chain_summary = chain_summary/sum(chain_summary)

output_stats = list()
for (this_chain in chains) {
  my_counts = clone_df[grepl(this_chain, clone_df$bestVHit), "cloneCount"]
  
  if(length(my_counts) != 0){
    # puts in the format x:y, where x is a number of clones, and y is the number of times that clone count occured
    count_output = summary(factor(my_counts), maxsum = Inf)
    count_output = paste0(names(count_output), ":", as.character(count_output), collapse = ";")
  } else {
    count_output = "none"
  }
  
  my_count = length(my_counts)
  my_shannon_entropy = shannon_entropy(my_counts)
  my_evenness = evenness(my_counts)
  my_inv_simpson = inv_simpson(my_counts)
  my_chao1 = as.numeric(estimateR(round(my_counts))["S.chao1"])
  
  output_stats[paste0(this_chain,"_Abundance")] = sum(my_counts)
  output_stats[paste0(this_chain,"_Fraction")] = chain_summary[this_chain]
  output_stats[paste0(this_chain,"_Richness")] = as.character(my_count)
  output_stats[paste0(this_chain,"_Counts")] = count_output
  output_stats[paste0(this_chain,"_Shannon_Entropy")] = format_floats(my_shannon_entropy)
  output_stats[paste0(this_chain,"_Evenness")] = format_floats(my_evenness)
  output_stats[paste0(this_chain,"_Inv_Simpson")] = format_floats(my_inv_simpson)
  output_stats[paste0(this_chain,"_Chao1")] = format_floats(my_chao1)
  
  #my_simpson_div
}

# reorder to put similar features next to one another
output_stats = output_stats[c(
  grep("_Abundance", names(output_stats)),
  grep("_Richness", names(output_stats)),
  grep("_Fraction", names(output_stats)),
  grep("_Shannon_Entropy", names(output_stats)),
  grep("_Evenness", names(output_stats)),
  grep("_Inv_Simpson", names(output_stats)),
  grep("_Chao1", names(output_stats)),
  grep("_Counts", names(output_stats))
 )]


my_headers = c(paste0(c("Sample_ID", names(output_stats)), collapse = ","))
my_stats = c(paste0(c(sample_id,unlist(output_stats)), collapse = ","))

writeLines(c(my_headers, my_stats), output_path)
