library(pdftools)
library(glue)
library(tidyverse)
library(stringr)
library(readr)

rm(list = ls())
#pdf_location 
docs <- list.files("PowerNetInput") 

column_order <- c("InvoiceMonth",
                  "DatasetMonth",
                  "UserType",
                  "ChargeType", 
                  "UnitPrice",
                  "Quantity", 
                  "TotalAmount",
                  "Company"
                  ) 

cost_list <- data.frame()

#scrape from each document
for(doc in docs){
  cost_doc <- pdf_text(pdf = paste("./PowerNetInput/", doc, sep = ""))  %>%
    strsplit(split = "\n") 
  
  
    ##the first page
    dataset_month <- cost_doc[[1]][14] %>%
      str_split(" {2,}", ,simplify = TRUE)
    
     invoice_month<- cost_doc[[1]][17] %>%
      str_split(" {2,}", ,simplify = TRUE)
    
    cost_tbl <- cost_doc[[1]][c(33,34)] %>%
      str_split(" {2,}", ,simplify = TRUE)
     
    
    cost_tbl <- data.frame(cost_tbl, stringsAsFactors = FALSE) 
    
    names(cost_tbl) <- c("a","ChargeType", "TotalAmount")  
    cost_tbl$InvoiceMonth<- invoice_month[3]    
    cost_tbl$UserType <- c("General User", "Low User" )
    cost_tbl$UnitPrice <- c("", "" )
    cost_tbl$Quantity <- c("", "" )
    
      
    cost_tbl$DatasetMonth  <- dataset_month[3]
    comp <- cost_doc[[2]][6] %>%
      str_split(" {2,}", ,simplify = TRUE)
    
    cost_tbl$Company <- comp[1]
    
    cost_tbl <- cost_tbl[, column_order]
    
    cost_list <- rbind(cost_list, cost_tbl)
    
  
  

}
write_csv(cost_list, "./output/PowerNet_cost_list.csv", col_names = TRUE)

