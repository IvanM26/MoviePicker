genres_list <- readRDS("data/genres-list.rds")

library(shiny)
library(tidyverse)
library(plotly)
library(DT)

ui <- fluidPage(
      
      titlePanel("Movie Picker"),
      
      sidebarLayout(
            
            sidebarPanel(
                  sliderInput(inputId = "avRat",
                              label = "Min Average Rating",
                              min = 6,
                              max = 10,
                              value = 6,
                              step = 0.5),
                  
                  sliderInput(inputId = "numVotes",
                              label = "Min Number of Votes",
                              min = 2500,
                              max = 100000,
                              value = 2500,
                              step = 1000, 
                              ticks = FALSE),
                  
                  sliderInput(inputId = "Year",
                              label = "Release Year",
                              min = 1980,
                              max = 2020,
                              value = c(1980,2020),
                              step = 5),
                  
                  sliderInput(inputId = "rtM",
                              label = "Runtime Minutes (RTM)",
                              min = 40,
                              max = 210,
                              value = c(40,210),
                              step = 10),
                  
                  checkboxGroupInput(inputId = "genre_list", 
                                     label = "Choose Genre/s (Up to 3)", 
                                     choices = genres_list$genres)
            ),
            
            mainPanel(
               tabsetPanel(
                  tabPanel("Plot & Table", 
                           # plotOutput("Vot_Rat", brush = "myBrush"),
                           plotlyOutput("Vot_Rat"),
                           br(),
                           br(),
                           br(),
                           br(),
                           br(),
                           dataTableOutput("table")
                  ),
                  tabPanel("About",
                           includeMarkdown("About.md"))
                  )
            )
      )
)

server <- function(input, output, session) {
   
   movies <- readRDS("data/movies.rds")
   
   movies_Reac <- reactive({
      if (is.null(input$genre_list)){
         filter(movies,
                numVotes >= input$numVotes,
                runtimeMinutes >= input$rtM[1] & runtimeMinutes <= input$rtM[2],
                startYear >= input$Year[1] & startYear <= input$Year[2],
                averageRating >= input$avRat)
      }
      
      else {
         filter(movies,
                numVotes >= input$numVotes,
                runtimeMinutes >= input$rtM[1] & runtimeMinutes <= input$rtM[2],
                startYear >= input$Year[1] & startYear <= input$Year[2],
                averageRating >= input$avRat,
                rowSums(sapply(input$genre_list, grepl, genres)) == length(input$genre_list)
                
         )
      }
   })
   
   

   output$Vot_Rat = renderPlotly({
      plotly::ggplotly(
      ggplot(movies_Reac(), aes(x = numVotes, y = averageRating)) +
         geom_point(aes(text = originalTitle), color = "blue", size = 0.5) +
         labs(title = "Number of Votes vs Average Rating",
              x = "Number of Votes",
              y = "Average Rating"
              ) +
         scale_x_continuous(limits = c(0, 2250000),
                            breaks = seq(0, 2000000, by = 500000),
                            labels = paste0(seq(0, 2000000, by = 500000)/1000, "K")) +
         scale_y_continuous(breaks = seq(6, 10, by = 1), 
                            labels = seq(6, 10, by = 1), 
                            limits = c(5.5,10)) +
         theme_minimal()
         , tooltip = "text", height = 500) %>% 
         event_register("plotly_selecting") %>% 
         layout(annotations = 
                   list(x = 0, 
                        y = -0.3, 
                        text = "Source: IMDB \nObs: A movie can have more than one genre", 
                        showarrow = F, 
                        xref = 'paper', yref = 'paper', 
                        xanchor = 'left', yanchor = 'auto', 
                        xshift = 0, yshift = 0,
                        align = "left",
                        font = list(size=11, color="black")),
                margin = 
                   list(
                      l = 50,
                      r = 50,
                      b = 150,
                      t = 50,
                      pad = 4
                   )
         )
   })
   
   output$table = renderDataTable({
      
      brush <- event_data("plotly_selecting")
      
      if (is.null(brush)){
         movies_Reac() %>%
            select(linkTitle, startYear, runtimeMinutes, genres, averageRating, numVotes) %>%
            arrange(-numVotes, -averageRating) %>%
            rename("Title" = "linkTitle",
                   "Release Year" = "startYear",
                   "Duration (Min)" = "runtimeMinutes",
                   "Genres" = "genres",
                   "Average Rating" = "averageRating",
                   "# Votes" = "numVotes"
            )
      }

      else {
         movies_Reac() %>%
            filter(rownames(movies_Reac()) %in% (brush$pointNumber + 1)) %>%
            select(linkTitle, startYear, runtimeMinutes, genres, averageRating, numVotes) %>%
            arrange(-numVotes, -averageRating) %>%
            rename("Title" = "linkTitle",
                   "Release Year" = "startYear",
                   "Duration (Min)" = "runtimeMinutes",
                   "Genres" = "genres",
                   "Average Rating" = "averageRating",
                   "# Votes" = "numVotes"
            )
      }

   }, escape = FALSE)

}

shinyApp(ui, server)
