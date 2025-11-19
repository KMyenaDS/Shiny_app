
# safe read for csv/xlsx/rds
read_data_file <- function(path, ext = NULL, sep = ",", header = TRUE){
  if (is.null(ext)) ext <- tools::file_ext(path)
  if (ext == "csv") {
    read.csv(path, sep = sep, header = header, stringsAsFactors = FALSE)
  } else if (ext %in% c("xls", "xlsx")) {
    readxl::read_excel(path)
  } else if (ext == "rds") {
    readRDS(path)
  } else stop("Type de fichier non supporté")
}
