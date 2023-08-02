# task_one

The task1.R is the script for converting the given ensembl gene names into entrez gene ids.

To run the script, using the following command:
Rscript --vanilla task1.R --input Homo_sapiens.gene_info.gz --gmt gmt h.all.v2023.1.Hs.symbols.gmt {--output /path/to/the/file.gmt}
1. User must provide values to --input & --gmt
2. The --output option, the part in {}, is optional. If no value provided to --output, the file will be stored in the working direcotry names out.gmt
