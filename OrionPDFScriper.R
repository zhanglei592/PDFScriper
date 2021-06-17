library(pdftools)
library(glue)
library(tidyverse)
library(stringr)
library(readr)

rm(list = ls())
#pdf_location 
docs <- list.files("OrionInput") 

column_order <- c("ScrapedDate",
                  "DatasetMonth",
                  "ChargeCategory",
                  "ChargeType",
                  "ChargeDescription",
                  "Quantity",
                  "QuantityDescription",
                  "TotalUnitcost",
                  "costDescription",
                  "TotalAmount",
                  "DocName"
                  ) 

cost_list <- data.frame()

#scrape from each document
for(doc in docs){
  cost_doc <- pdf_text(pdf = paste("./OrionInput/", doc, sep = ""))  %>%
    strsplit(split = "\n") 
  
  #scrape from PDF
  for (i in 1:length(cost_doc)) {
    ##the first page
    dataset_month <- cost_doc[[i]][3] %>%
      str_split_fixed(" {2,}", 2) %>%
      str_replace(", ", " ")
    
    cost_tbl <- cost_doc[[i]][c(10, 12, 15, 17, 23)]
    
    cost_tbl <- str_split_fixed(cost_tbl,  " {2,}", 6)
    
    cost_tbl <- data.frame(cost_tbl, stringsAsFactors = FALSE)
    
    names(cost_tbl) <- c("ChargeDescription",
                          "Quantity",
                          "QuantityDescription",
                          "TotalUnitcost",
                          "costDescription",
                          "TotalAmount") 
    
    cost_tbl$DatasetMonth <- dataset_month[2]  
    
    cost_tbl$ChargeCategory <- "GENERAL / IRRIGATION / STREETLIGHTING CONNECTIONS"
    
    cost_tbl$ChargeType <- c("FIXED",
                              "FIXED",
                              "VOLUME (GENERAL / IRRIGATION / STREETLIGHTING)",
                              "VOLUME (GENERAL / IRRIGATION / STREETLIGHTING)",
                              "PEAK (GENERAL / STREETLIGHTING)")
    
    cost_tbl$DocName <- doc
    cost_tbl$ScrapedDate <- Sys.Date()
    
    cost_tbl <- cost_tbl[, column_order]
    
    cost_list <- rbind(cost_list, cost_tbl)
    
  }
  

}
write_csv(cost_list, "./output/Orion_cost_list.csv", col_names = TRUE)

