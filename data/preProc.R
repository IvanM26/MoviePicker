"https://www.imdb.com/interfaces/"
"https://datasets.imdbws.com/"

# Load Libraries

library(tidyverse)

# Download IMDB Datasets (title.basics and title.ratings)

download.file("https://datasets.imdbws.com/title.basics.tsv.gz",
              destfile = "data/title.basics.tsv.gz")

download.file("https://datasets.imdbws.com/title.ratings.tsv.gz",
              destfile = "data/title.ratings.tsv.gz")

# Load Data in R

title.basics <- gzfile("data/title.basics.tsv.gz") %>%
      read_delim(
            "\t", 
            escape_double = FALSE, 
            na = "\\N", 
            trim_ws = TRUE, 
            quote='',
            col_types = cols(
                  tconst = col_character(), 
                  titleType = col_character(),
                  primaryTitle = col_character(),
                  originalTitle = col_character(),
                  isAdult = col_logical(),
                  startYear = col_integer(),
                  endYear = col_integer(),                 
                  runtimeMinutes = col_integer(), 
                  genres = col_character()))


title.ratings <- gzfile("data/title.ratings.tsv.gz") %>%
      read_delim("\t", 
                 escape_double = FALSE, 
                 na = "\\N", 
                 trim_ws = TRUE, 
                 quote='',
                 col_types = cols(
                       tconst = col_character(), 
                       averageRating = col_double(),
                       numVotes = col_integer()))

##### Pre-Processing #####

# Movies dataset
movies <- title.basics %>%
      filter(
            titleType == "movie",
            startYear >= 1980,
            runtimeMinutes >= 45 & runtimeMinutes <= 210
      ) %>%
      left_join(title.ratings, by = "tconst") %>%
      distinct %>%
      filter(
            averageRating >= 6,
            numVotes >= 2500
      ) %>%
   mutate(linkTitle = str_c("<a href='https://www.imdb.com/title/", tconst, "/'>", originalTitle,"</a>"))

# Save Movies dataset
saveRDS(movies, file = "data/movies.rds")

# Genres List
genres_list <- movies %>%
   select(genres) %>%
   separate_rows(genres, sep=",") %>%
   unique

# Save Genres List
saveRDS(genres_list, file = "data/genres-list.rds")

