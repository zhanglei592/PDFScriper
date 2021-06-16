library(pdftools)
library(glue)
library(tidyverse)
library(stringr)
library(readr)

rm(list = ls())
#pdf_location 
a <- list.files("input")
dir = paste("./input/", a, sep = "")
n = length(dir)

column_order <- c("DatasetMonth",
                      "ChargeCategory",
                      "ChargeType",
                      "ChargeDescription",
                      "Quantity",
                      "QuantityDescription",
                      "TotalUnitPrice",
                      "PriceDescription",
                      "TotalAmount") 

price_list <- data.frame()

for(doc in dir){
#the first PDF
price_doc <- pdf_text(pdf = doc)  %>%
  strsplit(split = "\n")



#scrape from PDF
for (i in 1:length(price_doc)) {
  ##the first page
  dataset_month <- price_doc[[i]][3] %>%
    str_split_fixed(" {2,}", 2) %>%
    str_replace(", ", " ")
  
  price_tbl <- price_doc[[i]][c(10, 12, 15, 17, 23)]
  
  all_price <- str_split_fixed(price_tbl,  " {2,}", 6)
  
  all_price <- data.frame(all_price, stringsAsFactors = FALSE)
  
  names(all_price) <- c("ChargeDescription",
                        "Quantity",
                        "QuantityDescription",
                        "TotalUnitPrice",
                        "PriceDescription",
                        "TotalAmount") 
  
  all_price$DatasetMonth <- dataset_month[2]  
  
  all_price$ChargeCategory <- "GENERAL / IRRIGATION / STREETLIGHTING CONNECTIONS"
  
  all_price$ChargeType <- c("FIXED",
                            "FIXED",
                            "VOLUME (GENERAL / IRRIGATION / STREETLIGHTING)",
                            "VOLUME (GENERAL / IRRIGATION / STREETLIGHTING)",
                            "PEAK (GENERAL / STREETLIGHTING)")
  
  all_price <- all_price[, column_order]
  
  price_list <- rbind(price_list, all_price)
  
}

}

write_csv(price_list, "./output/price_list.csv", col_names = TRUE)
