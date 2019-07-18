library(shiny)
library(ggplot2)
library(dplyr)

server <- function(input, output) {
  output$scatter1 <- renderPlot({
    title <- paste0(input$group1, " vs. ", input$group2, " Total Population")
    plot <- ggplot(midwest) +
      geom_point(mapping = aes_string(x = input$group1, y = input$group2)) +
                 labs(x = input$group1, y = input$group2, title = title)
    plot
  })
  output$scatter2 <- renderPlot({
    title <- paste0("Percent ", input$age, " Poverty in ", input$state)
    state_pop <- midwest %>%
      filter(state == input$state)
    plot <- ggplot(state_pop) +
      geom_point(mapping = aes_string(x = state_pop$poptotal, y = input$age)) +
      labs(x = "County Population",
           y = paste0("Percent ", input$age, " Poverty"),
           title = title)
    plot
  })
}