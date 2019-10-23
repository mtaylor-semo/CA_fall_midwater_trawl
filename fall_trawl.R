library(tidyverse)
library(lubridate)
library(stringr)


# Variables ---------------------------------------------------------------

# Instead of using system date for current year,
# could hard code for custom years? Would that be necessary?
start_year = 1967
end_year <- year(Sys.Date())

# Pattern for string extract
species_names <- c("Striped Bass|Delta Smelt|Longfin Smelt|American Shad|Splittail|Threadfin Shad")

# Add one line to get year range, 1 line for species name, and 1 line for column headers
chunk_length = end_year - start_year + 3 


# Functions ---------------------------------------------------------------

f = function(x, pos){
  sp_name <- str_extract(x[1], species_names) # pattern match to extract spp names
  x[1] <- str_replace_all(sp_name, " ", "_")
  x[1] <- str_to_lower(x[1])
#  filename <- paste(x[1], ".txt", sep="")
#  write_lines(x, path = filename)
  tsv <- read_tsv(x, skip = 1)            # read as tab-separated
  tsv <- mutate(tsv, species = sp_name)
  write_csv(tsv, paste0(x[1], ".csv"))    # write as csv
}  



# Wrangle master file -----------------------------------------------------
#
# Read in master file, save individual csv files
read_lines_chunked("ca_fall_trawl_data_raw.txt",
                   SideEffectChunkCallback$new(f), 
                   chunk_size = chunk_length)


# Read csv files ----------------------------------------------------------
#
# Convert to dataframe and arrange.

# Based on this blog post by Claus Wilke
# https://serialmentor.com/blog/2016/6/13/reading-and-combining-many-tidy-data-files-in-R
# See the comments for map_dfr(), files <- dir(pattern = "*.csv")
fishes_raw <- files %>% 
  map_dfr(~ read_csv(.))

fishes <- fishes_raw %>% 
  gather(key = month, value = number, Sept:Dec) %>% 
  select(species, Year, month, number)

fishes %>% 
#  filter(Total <= 10000) %>% 
  ggplot(aes(x = Year, y = number)) +
  geom_line() +
  facet_wrap(vars(species)) +
  geom_smooth(method = "lm")

## Try without Longfin Smelt, which has really high abundance
fishes_small <- fishes %>% 
  filter(species == "Delta Smelt" |
           species == "Splittail")

fishes_small %>% ggplot(aes(x = Year, y = Total)) +
  geom_line(aes(color = species))

fishes %>%
  group_by(species, Year) %>% 
  summarize(tot = sum(number, na.rm = TRUE)) %>% 
  ggplot(aes(x = Year, y = tot)) +
  geom_line() +
  facet_wrap(vars(species)) +
  geom_smooth(method = "lm")

