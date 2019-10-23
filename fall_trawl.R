library(tidyverse)
library(lubridate)
library(stringr)

# Instead of using system date for current year,
start_year = 1967
end_year <- year(Sys.Date())

# For string extract
species_names <- c("Striped Bass|Delta Smelt|Longfin Smelt|American Shad|Splittail|Threadfin Shad")

# Add one line to get year range, 1 line for species name, and 1 line for column headers
chunk_length = end_year - start_year + 3 

f = function(x, pos){
  x[1] <- str_extract(x[1], species_names)
  x[1] <- str_replace_all(x[1], " ", "_")
  x[1] <- str_to_lower(x[1])
  #  x[1] <- str_to_lower(x[1])
#  filename <- paste(x[1], ".txt", sep="")
#  write_lines(x, path = filename)
  tsv <- read_tsv(x, skip = 1)
  write_csv(tsv, paste0(x[1], ".csv"))
}  
read_lines_chunked("ca_fall_trawl_data_raw.txt",
                   SideEffectChunkCallback$new(f), 
                   chunk_size = chunk_length)
