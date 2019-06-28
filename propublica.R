library(httr, warn.conflicts = F)
library(jsonlite, warn.conflicts = F)
library(dplyr, warn.conflicts = F)
library(ggplot2, warn.conflicts = F)
source("api-keys.R")

# Accessing Propublica API
# then convert JSON output to R
chamber <- "house"
state <- "WA"
resource <- "members"
base_url <- "https://api.propublica.org/congress/v1/"
endpoint <- paste0(base_url, resource, "/", chamber,
                   "/", state, "/current.json")
response <- GET(endpoint, add_headers("X-API-Key" = propublica_api_key))
body <- content(response, "text")
parsed_data <- fromJSON(body)

# Extracting table of representatives from parsed data
state_reps <- parsed_data$results
state_reps$count <- 1

# Creating plot of representatives by gender
state_reps$gender[state_reps$gender == "M"] <- "Male"
state_reps$gender[state_reps$gender == "F"] <- "Female"
reps_by_gender <- ggplot(state_reps) +
  geom_col(mapping = aes(x = gender, y = count)) +
  coord_flip() +
  labs(x = "Number of Representatives") +
  labs(y = "Gender") +
  labs(title = "State Representatives by Gender")

# Creating plot of representatives by party affiliation
state_reps$gender[state_reps$gender == "R"] <- "Republican"
state_reps$gender[state_reps$gender == "D"] <- "Democrat"
reps_by_party <- ggplot(state_reps) +
  geom_col(mapping = aes(x = party, y = count)) +
  coord_flip() +
  labs(x = "Number of Representatives") +
  labs(y = "Party Affiliation") +
  labs(title = "State Representatives by Party Affiliation")

# Selecting the first listed representative
select_rep <- state_reps$id[1]

# Accessing the info about the selected representative from Propublica
# then convert from JSON to R
s_base_url <- "https://api.propublica.org/congress/v1/members/"
s_endpoint <- paste0(s_base_url, select_rep, ".json")
s_response <- GET(s_endpoint,
                  add_headers("X-API-Key" = propublica_api_key))
s_body <- content(s_response, "text")
s_parsed_data <- fromJSON(s_body)
s_info <- s_parsed_data$results

# Extracting information about the representative to present in the bio
s_full_name <- paste(s_info$first_name, s_info$last_name)
s_age <- 2019 - as.numeric(substr(s_info$date_of_birth, 1, 4))
s_twitter <- paste0("https://twitter.com/", s_info$twitter_account, "?lang=en")

# Accessing the info about how the selected representative votes from Propublica
# then convert from JSON to R
votes_base_url <- "https://api.propublica.org/congress/v1/members/"
votes_endpoint <- paste0(votes_base_url, select_rep, "/votes.json")
votes_response <- GET(votes_endpoint,
                  add_headers("X-API-Key" = propublica_api_key))
votes_body <- content(votes_response, "text")
votes_parsed_data <- fromJSON(votes_body)
votes_results <- votes_parsed_data$results
votes <- votes_results$votes[[1]]

# Calculating the percent vote agreement 
votes_passed <- votes %>%
  filter(position == "Yes") %>%
  filter(result == "Passed") %>%
  nrow()
votes_failed <- votes %>%
  filter(position == "No") %>%
  filter(result == "Failed") %>%
  nrow()
percent_agreed <- (votes_passed + votes_failed) / 20 * 100
