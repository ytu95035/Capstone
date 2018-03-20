# Capstone 
The final goal of this project is to build a text preditive model in Shiny application by using the SwifKey data set. 

## The first report -- Milestone Report 

This report explores three en_US Swifkey data sets with n-grams analysis.

## The Capstone final project -- Text Preddiction

### run ngram_prepare.R file to prepare 1, 2, 3, 4-gram RDS files.
Due to R memory issue, need to seperate the file into small chunk to n-gram process, then combine the file back to final file
### Shiny application file -- ui.R and server.R
Shiny App also include about.rmd file for the project documentation

## Shiny add link -- 

## 5 Slide presentation

### Capstoe_YTU.Rpres 

## Presentation link -- 


### Project Publish Method (use no firewall computer, the following process isn't necessary)
Due to company firewall issue, no file can be published into Rpubs and Shiny server.  
So, few workaronds are impemented and thank few of the contributor to post the workaround.

#### 1) publish html file into github

Tip from Michael Crump -- https://www.michaelcrump.net/how-to-run-html-files-in-your-browser-from-github/

html file link from github https://github.com/ytu95035/Data_Product/blob/master/index.html

Put it as in the following format: https://rawgit.com/ytu95035/Data_Product/master/index.html or https://cdn.rawgit.com/ytu95035/Data_Product/master/index.html

#### 2) Shiny web app hosting on github
the process is instructed by Abiyu Giday
http://abiyug.github.io/2016-04-05-shiny-web-app-hosting-on-github

Other people can view the app in their RStudio by run the following.

Step 6: From any R console with internet access run the following commands to launch your app. 
library(shiny)
#name of the app dir and username runGitHub("Capstone", "ytu95035")


