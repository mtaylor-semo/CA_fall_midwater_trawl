library(tidyverse)
library(lubridate)
library(stringr)

# Instead of using system date for current year,
start_year = 1967
end_year <- year(Sys.Date())

# Add one line to get year range, 1 line for species name, and 1 line for column headers
chunk_length = end_year - start_year + 3 

f = function(x, pos){
  
  filename = paste(x[1], ".txt", sep="")
  write_lines(x, path = filename)
}  
read_lines_chunked("ca_fall_trawl_data_raw.txt",
                   SideEffectChunkCallback$new(f), 
                   chunk_size = chunk_length)

read_tsv("chunk_1.txt", skip = 1)
