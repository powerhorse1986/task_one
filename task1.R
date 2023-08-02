if(!require("hash")) {
  install.packages("hash")
}
if(!require("optparse")) {
  install.packages("optparse")
}
library(tidyverse)
library(hash)
library(optparse)
setwd(getwd())
# build the option list
option_list <- list(
  make_option(c("-i", "--input"), type = "character", default = NULL,
              help = "path to input file", metavar = "character"),
  make_option(c("-o", "--output"), type = "character", default = "./out.gmt",
              help = "path to output file [default = %default]", metavar = "character")
)

# parse the option list
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# check if input file is given
if(is.null(opt$input)) {
  print_help(opt_parser)
  stop("At least one argument should be supplied (input file).n", call. = FALSE)
}

if(!file.exists(opt$input)) {
  stop("Input file does not exist, please make sure input a correct file path",
       call. = FALSE)
}

gene_map <- hash() # create a hash map

# read the Homo_sapiens.gene_info.gz into a dataframe
gene_info <- read_tsv(gzfile(opt$input))

# full fill the hashmap by iterating the dataframe
for(index in 1 : nrow(gene_info)) {
  record <- gene_info[index, ] # one row
  value <- record$GeneID # use the entrez gene id as the value
  symbols <- record$Symbol 
  
  # check if this gene has synonyms or not
  if(record$Synonyms != "-") {
    if(str_detect(record$Synonyms, "|")) { # if the string contains "|", split it
      synonyms_symbols <- strsplit(record$Synonyms, "|", fixed = TRUE)
    } else {
      synonyms_symbols <- record$Synonyms
    }
  }
  symbols <- c(symbols, synonyms_symbols) # combin the gene symbol and the synonyms
  for(symbol in symbols) { # store the gene symbols into the hashmap as key
    .set(gene_map, symbol, value)
  } 
}

# read in the gmt file
gmt_df <- read_tsv("h.all.v2023.1.Hs.symbols.gmt", col_names = FALSE)
for(index in 1 : nrow(gmt_df)) {
  record <- gmt_df[index, ]
  for(i in 3 : length(record)) {
    gmt_df[index, i] <- as.character(gene_map[[record[[i]]]])
  }
}
print(gmt_df)
write_tsv(gmt_df, opt$output, col_names = FALSE)
