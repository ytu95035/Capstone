### Author: Yulin Tu
### Date: March 19, 2018
### server.R file for Capstone Shiny app
### Github repo : https://github.com/ytu95035/Capstone

# load library
suppressWarnings(library(shiny))
suppressWarnings(library(tm))
suppressWarnings(library(dplyr))
suppressWarnings(library(stringr))

# load 4 n-gram rds
gram1 <- readRDS(file="gram1.rds")
gram2 <- readRDS(file="gram2.rds")
gram3 <- readRDS(file="gram3.rds") 
gram4 <- readRDS(file="gram4.rds")
badword <- readLines("bad_word.txt")

# clean input string firt
cleantext <- function(x) {
  xstr <- iconv(x, "latin1", "ASCII", sub=" "); 
  xstr <- gsub("[^[:alpha:][:space:][:punct:]]", "", xstr); 
  xstr <- removeNumbers(removePunctuation(tolower(xstr)));
  xstr <- stripWhitespace(removeWords(xstr, badword))
  xstr <- strsplit(xstr, " ")[[1]]
  if (nchar(xstr) > 0) { 
  return(xstr) } 
  else { 
    return("") }
} 
#--------------------------------------- 
# Description of Katz's Back Off Algorithm 
#--------------------------------------- 
# To predict the next word of the user specified sentence (4 gram files are sorting by frequence already)
# 1. Use a 4-Gram first, the first three words of 4-Gram are the last three words of the sentence) 
# 2. If no 4-Gram is found, we back off to 3-Gram (first two words of 3-Gram are the last two words of the sentence) 
# 3. If no 3-Gram is found, we back off to 2-Gram (first word of 2-Gram is the last word of the sentence) 
# 4. If no 2-Gram is found, we back off to 1-Gram (the most common word with highest frequency) 
  
Predword <- function(xstr) 
  { 
    assign("mesg", "in Predword") 
    # call cleantext & get length of sentence
    xstr <- cleantext(xstr); 
    xstrLen <- length(xstr); 
    
    nxtTermFound <- FALSE; 
    predword <- as.character(NULL); 
    mesg <<- "" 
    
    # 1. Use a 4-Gram first
    if (xstrLen >= 3 & !nxtTermFound) 
      { 
        xstr1 <- paste(xstr[(xstrLen-2):xstrLen], collapse=" "); 
        searchStr <- paste("^",xstr1, sep = ""); 
        gram4tmp <- gram4[grep (searchStr, gram4$word), ]; 
        
        # valrify if any matching record found
        if ( length(gram4tmp[, 1]) > 1 ) 
         { 
           predword <- gram4tmp[1,1]; 
            nxtTermFound <- TRUE; 
            mesg <<- "Next word is predicted by 4-gram." 
          } 
        gram4tmp <- NULL; 
      } 
    
    # 2. If no 4-Gram is found, we back off to 3-Gram
    if (xstrLen >= 2 & !nxtTermFound) 
      { 
        xstr1 <- paste(xstr[(xstrLen-1):xstrLen], collapse=" "); 
        searchStr <- paste("^",xstr1, sep = ""); 
        gram3tmp <- gram3[grep (searchStr, gram3$word), ]; 
        
        # valrify if any matching record found
        if ( length(gram3tmp[, 1]) > 1 ) 
          { 
            predword <- gram3tmp[1,1]; 
            nxtTermFound <- TRUE; 
            mesg <<- "Next word is predicted by 3-gram." 
            } 
        gram3tmp <- NULL; 
         } 

     # 3. If no 3-Gram is found, we back off to 2-Grame 
    if (xstrLen >= 1 & !nxtTermFound) 
       { 
        xstr1 <- xstr[xstrLen]; 
        searchStr <- paste("^",xstr1, sep = ""); 
        gram2tmp <- gram2[grep (searchStr, gram2$word), ]; 
        
         # valrify if any matching record found
          if ( length(gram2tmp[, 1]) > 1 ) 
            { 
                predword <- gram2tmp[1,1]; 
                nxtTermFound <- TRUE; 
                mesg <<- "Next word is predicted by 2-gram."; 
          } 
          gram2tmp<- NULL; 
        } 
    
    
    # 4. If no 2-Gram is found, we back off to 1-Gram
    if (!nxtTermFound & xstrLen > 0) 
      { 
        predword <- gram1$word[1]; 
        mesg <- "No next word found, the most frequent 1-gram word is selected as next word." 
      } 
    
    
    nextTerm <- word(predword, -1); 
    
    if (xstrLen > 0){ 
      dfword <- data.frame(nextTerm, mesg); 
        return(dfword); 
       } else { 
          nextTerm <- ""; 
           mesg <-"Can not find the next word, please enter other phrases. Thank you"; 
        dfword <- data.frame(nextTerm, mesg); 
        return(dfword); 
      } 
  } 
  
shinyServer(function(input, output, session) {

  observeEvent(
      eventExpr = input[["submitbtn"]],
      handlerExpr = {
        withProgress(message = 'Just a moment...', value = 0, {
        })
 
    output$prediction <- renderPrint({
      str1 <- cleantext(input$text);
      result <- Predword(input$text) 
      cat("", as.character(result[1,1])) 
      
      output$text3 <- renderText({mesg})
      output$text2 <- renderText({
        str1}) 
    })
    
    output$text1 <- renderText({
      input$text}) 
  })
 }
)     