library(httr, warn.conflicts = F)
library(jsonlite, warn.conflicts = F)
library(dplyr, warn.conflicts = F)
source("api-keys.R")

# Defining the query parameters
address <- "2850 NW 29th Ave, Camas, WA 98607"
resource <- "representatives"
base_url <- "https://www.googleapis.com/civicinfo/v2/"
endpoint <- paste0(base_url, resource)
query_params <- list(address = address, key = google_api_key)

# Accessing the Civic Info API and converting the output to R
response <- GET(endpoint, query = query_params)
body <- content(response, "text")
parsed_data <- fromJSON(body)

# Data wrangling (assuming that `parsed_data` is the parsed JSON response)
state_info <- parsed_data$normalizedInput
offices <- parsed_data$offices
officials <- parsed_data$officials

# Expand officies by the number of elements in the `indices` column
# See: https://stackoverflow.com/questions/2894775/replicate-each-row-of-data-frame-and-specify-the-number-of-replications-for-each
#(Links to an external site.)Links to an external site.
num_to_rep <- unlist(lapply(parsed_data$offices$officialIndices, length))
expanded <- offices[rep(row.names(offices), num_to_rep), ]
officials <- officials %>% mutate(index = row_number() - 1)
expanded <- expanded %>% mutate(index = row_number() - 1) %>%
  rename(position = name)

# Joining the two tables of representatives
representatives <- full_join(expanded, officials, by = "index")

# Creating the table of relevant information to be displayed in the report
rep_table <- data.frame(representatives[7], representatives[1],
                        representatives[9], representatives[14],
                        representatives[10], representatives[12])

# Formatting the table of representatives for more clarity
rep_table$emails[rep_table$emails == "NULL"] <- "Not Available"
names(rep_table)[1:6] <- c("Name", "Position", "Party",
                           "Email", "Phone", "Photo")

# Formatting the photo urls so that they display when passed into the rmd file
url_to_photo <- paste0("![](", rep_table$Photo[is.na(rep_table$Photo) == F],
                       ")")
rep_table$Photo[is.na(rep_table$Photo) == F] <- url_to_photo

# Adding hyperlink to representative name
rep_table[1] <- paste0("[", representatives$name, 
                       "](", representatives$urls, ")")