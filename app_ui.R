library(ggplot2)
library(shiny)

names(midwest)[7:11] <- c("White", "Black", "American_Indian",
                           "Asian", "Other")
group_values <- colnames(midwest)[7:11]

group1_select <- selectInput(
  "group1",
  label = "Ethnicity 1",
  choices = group_values,
  selected = "White"
)
group2_select <- selectInput(
  "group2",
  label = "Ethnicity 2",
  choices = group_values,
  selected = "White"
)
scatter1_plot <- tabPanel(
  h1("Comparison of Population by Ethnicity"),
  sidebarLayout(
    sidebarPanel(
      group1_select,
      group2_select
    ),
    mainPanel(
      plotOutput("scatter1")
    )
  )
)

state_values <- unique(midwest$state)
names(midwest)[24:26] <- c("Child", "Adult", "Elderly")
age_values <- colnames(midwest)[24:26]

age_select <- radioButtons(
  "age",
  label = h3("Select Age Group"),
  choices = age_values,
  selected = "Child"
  )
state_select <- radioButtons(
  "state",
  label = h3("Select a State"),
  choices = state_values,
  selected = "IL"
)
scatter2_plot <- tabPanel(
  h1("Poverty by Age Group and State"),
  sidebarLayout(
    sidebarPanel(
      age_select,
      state_select
    ),
    mainPanel(
      plotOutput("scatter2")
    )
  )
)

ui <- navbarPage(
  "Midwest Demographics",
  scatter1_plot,
  scatter2_plot
)