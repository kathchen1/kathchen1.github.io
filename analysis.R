# Analysis Setup
library(dplyr)
library(tidyr)
library(ggplot2)
shootings <- read.csv("data/shootings-2018.csv", stringsAsFactors = F)

# Summary Information
num_total_shootings <- nrow(shootings)
lives_lost <- sum(shootings$num_killed)
city_most_impact <- shootings %>%
  group_by(city) %>%
  summarize(num_shootings = n()) %>%
  filter(num_shootings == max(num_shootings)) %>%
  pull(city)
shootings_only_injured <- shootings %>%
  filter(num_killed == 0) %>%
  nrow()
num_states_affected <- n_distinct(shootings$state)

# Summary Table
shootings$month <- months(as.Date(shootings$date, "%B %d,%Y"))
shootings_by_month <- shootings %>%
  group_by(month) %>%
  summarize(num_shootings_month = n(),
            num_killed_month = sum(num_killed),
            num_injured_month = sum(num_injured)) %>%
  arrange(match(month, month.name))
names(shootings_by_month)[1] <- "Month"
names(shootings_by_month)[2] <- "Number of Shootings"
names(shootings_by_month)[3] <- "Total Lives Lost"
names(shootings_by_month)[4] <- "Total Injured"

# Thousand Oaks Shooting
th_oaks <- shootings %>%
  filter(city == "Thousand Oaks")

# Plot of lives affected organized by region
shootings$region <- state.region[match(shootings$state, state.name)]
shootings$region[is.na(shootings$region)] <- "Northeast"
shootings <- shootings %>%
  rename(Killed = num_killed) %>%
  rename(Injured = num_injured)
shootings_by_state <- shootings %>%
  select(region, Killed, Injured) %>%
  gather(key = lives_affected, value = num_affected, -region)
shootings_by_region <- ggplot(shootings_by_state) +
  geom_col(mapping = aes(x = region, y = num_affected, fill = lives_affected)) +
  labs(x = "Region of the United States") +
  labs(y = "Number of Lives Affected") +
  labs(fill = NULL) +
  labs(title = "Lives Affected by Mass Shootings by Region") +
  labs(caption = "For the purpose of this visualization,
       Washington DC has been included in the Northeast region.")