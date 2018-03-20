### Author: Yulin Tu
### Date: March 19, 2018
### server.R file for Capstone Shiny app
### Github repo : https://github.com/ytu95035/Capstone

# load library
suppressWarnings(library(shiny))
suppressWarnings(library(markdown))

shinyUI(navbarPage("Data Science Capstone Project",
                   tabPanel("Next Word Predition",
                            # Sidebar
                            sidebarLayout(
                              sidebarPanel(

                                helpText("Input a word, a sentence or a phrase and click <Predict> to see the next word:"),
                                textInput(inputId="text", label = ""),
                                actionButton(inputId = "submitbtn",
                                             label = "Predict"
                                ),
                                fluidRow(HTML("<div style='margin-left:18px;margin-bottom:18px;color:navy;'><strong>Date: March 19, 2018</strong></div>") ),
                                fluidRow(HTML("<div style='margin-left:18px;margin-bottom:18px;margin-top:-18px;color:navy;'><strong><big>By Yuling Tu</big></strong></div>") ) 
                              ),
                        mainPanel(
                                h1("Your Next Word Prediction"),
                                h4("The word, sentence or phrase you entered"),
                                tags$style(type='text/css', '#text1 {background-color: rgba(255,255,0,0.40); color: blue;}'), 
                                textOutput('text1'),
                                h4("The word, sentence or phrase sends for predition"),
                                tags$style(type='text/css', '#text2 {background-color: rgba(255,255,0,0.40); color: blue;}'), 
                                textOutput('text2'),
                                h3("Next Word"),
                                verbatimTextOutput("prediction"),
                                strong("Note:"),
                                tags$style(type='text/css', '#text3 {background-color: rgba(255,255,0,0.40); color: blue;}'),
                                textOutput('text3')
                                )
                            )
                  ),
                   tabPanel(p(icon("info"), "About"),
                            mainPanel(
                              includeMarkdown("about.html")
                            )
                   )
))