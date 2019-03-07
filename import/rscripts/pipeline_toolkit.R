
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# format_bigquery_output
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
format_bigquery_output = function(my_data, my_cast){
  
  
  if(my_data %in% c("NA", "Na", "NaN", "NULL", "null", "Null")){
    my_data = ""
  } else if(my_cast == "float"){
    if(!grepl(".", my_data, fixed = TRUE)){
      my_data = paste0(my_data, ".0")
    } 
  } else if(my_cast == "int"){
    my_data = round(as.numeric(my_data))
  }
  return(my_data)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# extract_data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extract_data = function(extraction_list, input_path, column_tag){
  if(!file.exists(input_path)){
    cat(paste0("File (", input_path,") does not exist, Stupid.\n"))
    return(NULL)
  } else {
    input_lines = readLines(input_path)
    data_output = c()
    for (extraction_item in extraction_list){
      my_prefix = extraction_item[1]
      my_cast = extraction_item[2]
      my_line = input_lines[grepl(my_prefix, input_lines, fixed = TRUE)]
      # at this point we just know the string is in there.  we need to check results to make sure the string is at the begining
      #   but we can't use a ^ because the lines may have funky characters and we need fixed = T
      positions = c()
      for (each_line in my_line){
        positions = c(positions, regexpr(my_prefix, each_line, fixed=T)[1])
      }
      my_line = my_line[positions == 1]
      
      my_line = my_line[length(my_line)]  # if there's more than one line take the last one (it's more recent)
      # can't have a comma in the prefix/line or else it will be 
      #       my_line = gsub(",","-", my_line)
      #       my_prefix = gsub(",","-", my_prefix)
      if(length(my_line) == 1){
        my_data = gsub(my_prefix, "", my_line, fixed = TRUE)
        my_data = format_bigquery_output(my_data, my_cast)
      } else {
        cat(paste0("Could not find line containing ,", my_prefix, "'\n"))
        my_data = ""
      }
      
      data_output = paste0(c(data_output, my_data), collapse = ",")
    }
    column_titles = paste0(paste0(column_tag, names(extraction_list)), collapse = ",")
    return(list(column_titles,data_output))
  }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# shannon_entropy
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shannon_entropy <- function(counts)
  #https://stat.ethz.ch/pipermail/r-help/2008-July/167112.html
{
  if ( sum(counts) <= 0 || min(counts) < 0 )
    return(NA)
#   counts.norm <- counts[counts>0]/sum(counts)
#   -sum(log(counts.norm)*counts.norm)
  diversity(counts, index = "shannon")
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# inv_simpson
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
inv_simpson <- function(counts)
  #https://stat.ethz.ch/pipermail/r-help/2008-July/167112.html
{
  if ( sum(counts) <= 0 || min(counts) < 0 )
    return(NA)
  #   counts.norm <- counts[counts>0]/sum(counts)
  #   -sum(log(counts.norm)*counts.norm)
  diversity(counts, index = "invsimpson")
}



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# evenness
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
evenness <- function(counts){  
  if ( sum(counts) <= 0 || min(counts) < 0 || length(counts) <= 1 )
    return(NA)
  shannon_entropy(counts)/log(sum(!is.na(counts)))
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# format_floats
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# so bigquery will interpret them correctly...
#   let NA be blank
#   make sure floats have zeroes behind them
#   return as characters
format_floats <- function(my_num){
  if(is.na(my_num)) {
    my_num = ""
  } else {
    my_num = as.character(my_num)
    if(!grepl(".", my_num, fixed = T)){
      my_num = paste0(my_num, ".0")
    }
  }
  return(my_num)
}
  
# "Inverse_Simpson"
#diversity(V_J_CDR3_counts[[this_sample]], index = "invsimpson", MARGIN = 2, base = exp(1))
