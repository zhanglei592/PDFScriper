library(pdftools)
library(glue)
library(tidyverse)
library(stringr)
library(readr)

rm(list = ls())
#pdf_location 
docs <- list.files("OrionInput") 

column_order <- c("InvoiceMonth",
                  "DatasetMonth", 
                  "ChargeType", 
                  "ChargeDescription",
                  "Quantity", 
                  "TotalUnitcost", 
                  "TotalAmount",
                  "a",
                  "b" ,
                  "TotalAmount"
                  ) 

cost_list <- data.frame()

#scrape from each document
for(doc in docs){
  cost_doc <- pdf_text(pdf = paste("./OrionInput/", doc, sep = ""))  %>%
    strsplit(split = "\n") 
  
  #scrape from PDF
  for (i in 1:length(cost_doc)) {
    ##the first page
    invoice_month <- cost_doc[[i]][4] %>%
      str_split_fixed(" {2,}", 2) %>%
      str_replace(", ", " ")
    
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
    
    cost_tbl$ChargeType <- c("FIXED",
                              "FIXED",
                              "VOLUME (GENERAL / IRRIGATION / STREETLIGHTING)",
                              "VOLUME (GENERAL / IRRIGATION / STREETLIGHTING)",
                              "PEAK (GENERAL / STREETLIGHTING)") 
    
    cost_tbl$ChargeDescription <- c("GENERAL CONNECTION FIXED DAILY CHARGE",
                                    "FIXED STREETLIGHTING",
                                    "WEEKDAYS 7AM - 9PM",
                                    "NIGHTS, WEEKENDS, AND HOLIDAYS",
                                    "PEAK PERIOD DEMAND")
    
    cost_tbl$a <- c("")
    cost_tbl$b <- c("")
    cost_tbl$InvoiceMonth <- invoice_month[2]
    
    cost_tbl <- cost_tbl[, column_order]
    
    cost_list <- rbind(cost_list, cost_tbl)
    
  }
  

}
 

  write_csv(cost_list, "./output/Orion_cost_list.csv", col_names = TRUE)

