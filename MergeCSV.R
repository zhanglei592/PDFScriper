library("dplyr")                                                
library("plyr")                                                   
library("readr")  

#Merge CSV
data_all <- list.files(path = "Merge", pattern = "*.csv", full.names = TRUE) 

data <- do.call(rbind, lapply
        (data_all, read.csv, as.is=T, skip = 1, header = FALSE))

write_csv(data, "./output/PowerNet_cost_list.csv", col_names = FALSE)



#Merge TXT
txt_all <- list.files(path = "Merge", pattern = "*.txt", full.names = TRUE) 

poco <- do.call(rbind, lapply
                (txt_all, read.csv, as.is=T, skip = 1, header = FALSE))

write_csv(poco, "./output/POCO_cost_list.csv", col_names = FALSE)
