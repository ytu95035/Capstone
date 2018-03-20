### Author: Yulin Tu
### Date: March 19, 2018
### prepare_ngram.R file for Capstone Shiny app
### Github repo : https://github.com/ytu95035/Capstone

# load library
library(ANLP)
library(dplyr)
library(tidyr)
library(stringi)
library(tm)
library(RWeka)
library(ngram)
library(data.table)

## Loading the original data set
blogs <- readLines("./data/en_US.blogs.txt", ok = TRUE, warn = TRUE, encoding = "UTF-8", skipNul=TRUE)
news <- readLines("./data/en_US.news.txt", ok = TRUE, warn = TRUE, encoding = "UTF-8", skipNul=TRUE)
twitter <- readLines("./data/en_US.twitter.txt", ok = TRUE, warn = TRUE, encoding = "UTF-8", skipNul=TRUE)

## combining 10% sample data from three files
set.seed(888)
bsample <- sample(blogs, length(blogs)*0.1, replace = FALSE)
nsample <- sample(news, length(news)*0.1, replace = FALSE)
tsample <- sample(twitter, length(twitter)*0.1, replace = FALSE)
## combine three sample together
allsample  <- c(bsample,nsample,tsample)
# remove three sample files to free space
rm(bsample, nsample, tsample, blogs, news, twitter) 

# remove non-en characters 
allsample <- iconv(allsample, "latin1", "ASCII", sub="")
allsample <- gsub("[^[:alpha:][:space:][:punct:]]", "", allsample) 
# load bad_word file
badword <- readLines("./data/bad_word.txt")

# use more processor core power if applicable
options(mc.cores = 10)  
# mclapply gets the number of cores from global options
tm_parLapply_engine(parallel::mclapply) 

# files are still big, need to put the process into chunk 
# and save to specified gram folder

dtnameA <- "./data/gram1/df1_" 
dtnameB <- "./data/gram2/df2_" 
dtnameC <- "./data/gram3/df3_"
dtnameD <- "./data/gram4/df4_"

totallen <- length(allsample) 
size<- 2500
npart <- as.integer(totallen/size) 

for (i in 1:npart ) { 
  j <- (i-1)*size+1 
  k <- i*size 
  chunksample <- allsample[j:k] 
  
  # create corpus
  chunkcorpus <- VCorpus(VectorSource(chunksample))
  #convert to lower case
  chunkcorpus <- tm_map(chunkcorpus, content_transformer(tolower))
  #remove all numbers
  chunkcorpus <- tm_map(chunkcorpus, removeNumbers)
  #remove all punctuation
  chunkcorpus <- tm_map(chunkcorpus, removePunctuation)
  #remove all white spaces
  chunkcorpus <- tm_map(chunkcorpus, stripWhitespace)
  #remove bad word
  chunkcorpus <- tm_map(chunkcorpus,removeWords, badword)
  # Remove stopwords -- keep stop work for shiny app
  #chunkcorpus <- tm_map(chunkcorpus, removeWords, stopwords("english"))

  dt1 <- generateTDM(chunkcorpus,1,isTrace=F)
  dt2 <- generateTDM(chunkcorpus,2,isTrace=F)
  dt3 <- generateTDM(chunkcorpus,3,isTrace=F)
  dt4 <- generateTDM(chunkcorpus,4,isTrace=F)
  
  dtname1 <- paste(dtnameA,i,sep="") 
  dtname2 <- paste(dtnameB,i,sep="")
  dtname3 <- paste(dtnameC,i,sep="")
  dtname4 <- paste(dtnameD,i,sep="")
    
  write.table(dt1, dtname1, col.names = TRUE) 
  write.table(dt2, dtname2, col.names = TRUE) 
  write.table(dt3, dtname3, col.names = TRUE) 
  write.table(dt4, dtname4, col.names = TRUE) 

print(i) 
} 

#==================================================================
# create a function to merge file and sum the frequence
mergeFile <- function (df1, df2){ 
  df1 <- df1[order(df1$word),] 
  df2 <- df2[order(df2$word),] 
  df1$freq[df1$word %in% df2$word] <- df1$freq[df1$word %in% df2$word] + df2$freq[df2$word %in% df1$word] 
  df3 <- rbind(df1, df2[!(df2$word %in% df1$word),]) 
  df3 
} 

# combine 1-gram files and save freq >50 to rds file
gram_final <- "./data/gram1_final" 
gram_name1 <- "./data/gram1/df1_" 

wf1_old <- data.frame(word=NA, freq=NA)[numeric(0), ] 
for (i in 1:npart ) { 
  dtname1 <- paste(dtnameA,i,sep="") 
  wf1 <- read.table(dtname1, header = TRUE) 
  wf1_new <- mergeFile(wf1_old, wf1) 
  wf1_old <- wf1_new 
  print(i) 
  } 

wf1_new <- wf1_new[with(wf1_new, order(-freq)), ] 
write.table(wf1_new, gram_final, col.names = TRUE) 
#View(head(wf1_new))
gram1 <- read.table(gram_final, header = TRUE, stringsAsFactors = FALSE) 

# Subset the data frames based on the frequency 
gram1 <- gram1[gram1$freq > 50,] 
saveRDS(gram1, file="./data/gram1.rds")
#====================================================================

# combine 2-gram files and save freq >2 to rds file
gram_final <- "./data/gram2_final" 
gram_name1 <- "./data/gram2/df2_" 

wf1_old <- data.frame(word=NA, freq=NA)[numeric(0), ] 
for (i in 1:npart ) { 
  dtname2 <- paste(dtnameB,i,sep="") 
  wf1 <- read.table(dtname2, header = TRUE) 
  wf1_new <- mergeFile(wf1_old, wf1) 
  wf1_old <- wf1_new 
  print(i) 
} 

wf1_new <- wf1_new[with(wf1_new, order(-freq)), ] 
write.table(wf1_new, gram_final, col.names = TRUE) 
#View(head(wf1_new))
gram2 <- read.table(gram_final, header = TRUE, stringsAsFactors = FALSE) 

# Subset the data frames based on the frequency 
gram2 <- gram2[gram2$freq > 2,] 
saveRDS(gram2, file="./data/gram2.rds")
#==================================================================

# combine 3-gram files and save freq >1 to rds file
gram_final <- "./data/gram3_final" 
gram_name1 <- "./data/gram3/df3_" 

wf1_old <- data.frame(word=NA, freq=NA)[numeric(0), ] 
for (i in 1:npart ) { 
  dtname3 <- paste(dtnameC,i,sep="") 
  wf1 <- read.table(dtname3, header = TRUE) 
  wf1_new <- mergeFile(wf1_old, wf1) 
  wf1_old <- wf1_new 
  print(i) 
} 

wf1_new <- wf1_new[with(wf1_new, order(-freq)), ] 
write.table(wf1_new, gram_final, col.names = TRUE) 
#View(head(wf1_new))
gram3 <- read.table(gram_final, header = TRUE, stringsAsFactors = FALSE) 

# Subset the data frames based on the frequency 
gram3 <- gram3[gram3$freq > 1,] 
saveRDS(gram3, file="./data/gram3.rds")
#=======================================================================

## combine 4-gram files and save freq >50 to rds file
gram_final <- "./data/gram4_final" 
gram_name1 <- "./data/gram4/df4_" 

wf1_old <- data.frame(word=NA, freq=NA)[numeric(0), ] 
for (i in 1:npart ) { 
  dtname4 <- paste(dtnameD,i,sep="") 
  wf1 <- read.table(dtname4, header = TRUE) 
  wf1_new <- mergeFile(wf1_old, wf1) 
  wf1_old <- wf1_new 
  print(i) 
} 

wf1_new <- wf1_new[with(wf1_new, order(-freq)), ] 
write.table(wf1_new, gram_final, col.names = TRUE) 
#View(head(wf1_new))
gram4 <- read.table(gram_final, header = TRUE, stringsAsFactors = FALSE) 

# Subset the data frames based on the frequency 
gram4 <- gram4[gram4$freq > 1,] 
saveRDS(gram4, file="./data/gram4.rds")
#=====================================================================

## read the file
readRDS(file="./data/gram1.rds")
readRDS(file="./data/gram2.rds")
readRDS(file="./data/gram3.rds") 
readRDS(file="./data/gram4.rds")
