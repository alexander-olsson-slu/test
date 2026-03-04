#######--------- Maturity analyses herring -------------#######

##¤ Open Libraries

library(data.table)
library(readr)
library(dplyr)

## Working directory

dir <- "C:/R_Analyser/Herring_maturity/fromMalin"
setwd(dir)

#### --- Load data with maturity information and combine maturity scales to one SMSF scale -----####

## Read in the data files

herr_type2 <- fread("typ_2_Commercial_samples_s_without_st.csv") # Bias 1995-2024
herr_type3 <- fread("typ_3_2020-2024 Commercial_samples_s_without_st.csv") # Spras 2020-2024
herr_type4 <- fread("typ_4_Commercial_samples_s_without_st.csv") # Commercial 1995-2021
herr_type7 <- fread("typ_7_Commercial_samples_s_without_st.csv") # Provtagning pelagisk fisk 2020-2024
herr_type8 <- fread("typ_8_Commercial_samples_s_without_st.csv") # Industrifisk 1993-2020
herr_type16 <- fread("typ_16_Commercial_samples_s_without_st.csv")# RU-SPRAS 2024

## number of rows and columns
dim(herr_type2)
dim(herr_type8)
dim(herr_type16)

## Combine the data tables
herr_data <- rbind(herr_type2, herr_type3, herr_type4, herr_type7, herr_type8, herr_type16)

###### translate old mat scales to SMSF scale #####

## rename data.tables
mat_code <- herr_type2

## Check structure
str(mat_code)

## rename columns for clarity
setnames(mat_code, old = c("Maturity No (SMSF)"), new = c("MaturitySMSF"))
setnames(mat_code, old = c("Lengthclass (mm)"), new = c("Lengthclass_mm"))
setnames(mat_code, old = c("Sampling type"), new = c("Sampling_type"))
setnames(mat_code, old = c("Weight (g)"), new = c("Weight_g"))


## Convert MaturitySMSF column to integer type
mat_code[, MaturitySMSF := as.numeric(MaturitySMSF)]    
mat_code[, Maturity := as.numeric(Maturity)]
mat_code[, Year := as.numeric(Year)]
str(mat_code)

## Check unique values in key columns 
unique(mat_code$Maturity) 
unique(mat_code$MaturitySMSF) 
unique_values <- unique(mat_code[Year == 2023 & !is.na(MaturitySMSF), MaturitySMSF])
unique_values <- unique(mat_code[Maturity & !is.na(Maturity), Year])
print(unique_values)

explore<-mat_code[Year==1995 & !is.na(Maturity),.N, by=.(Mat
explore<-mat_code[!is.na(Maturity),.N, by=.(Year, Maturity)]

### Recode Maturity values to match MaturitySMSF scale in a new column 
herr_fixed<- mat_code[, Maturity_Recode := fifelse(Year >= 1990 & Year <= 2023 & Maturity == 1, 1,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 2, 21,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 3, 22,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 4, 22,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 5, 31,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 6, 32,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 7, 41,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 8, 41,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 81, 41,
                      fifelse(Year >= 1990 & Year <= 2023 & Maturity == 82, 42, NA_integer_))))))))))]

str(herr_fixed)

### Combine columns to create a final maturity code in new column
herr_fixed<- herr_fixed[, Maturity_Final := fifelse(!is.na(MaturitySMSF), MaturitySMSF,
                             fifelse(!is.na(Maturity_Recode), Maturity_Recode, NA_integer_))]  

str(herr_fixed)
dim(herr_fixed)
sum(is.na(herr_fixed$Maturity_Final))

## remove years without maturity_Final data
herr_fixed <- herr_fixed[!is.na(Maturity_Final)]
dim(herr_fixed)

# remove columns not needed for maturity analysis
herr_fixed <- herr_fixed[, !c("Stomach sample (code)", "Dna Code", "Age reader", "Maturity stager", "Spmen note", "V40", "V41", "V42", "V43"), with = FALSE]


## Create a binary maturity column. Börja med att ta med 31,32 som mogna, inkludera 41 senare 
herr_fixed[, Maturity_Binary := ifelse(Maturity_Final %in% c(31, 32), 1, 0)]
unique(herr_fixed$Maturity_Binary)

##save fixed data
fwrite(herr_fixed, "herring_maturity_fixed.csv")

#### ---------- Compute Maturity-Length Key (MLK)-----####  

### Load fixed maturity data 
herr_fixed <- fread("herring_maturity_fixed.csv")
print(names(herr_fixed))   

### Compute proportion mature per length class grouped by SamplingType, Year, Trip, Station, and Lengthclass

maturity_length_key <- herr_fixed[, .(
  Proportion_Mature = sum(Maturity_Binary == 1, na.rm = TRUE) / .N  # Proportion of mature individuals
), by = .(Sampling_type, Year, Trip, Station, Lengthclass_mm)]

  # Order the result by SamplingType, Year, Trip, Station, and Lengthclass
  setorder(maturity_length_key, Sampling_type, Year, Trip, Station, Lengthclass_mm)

  # View the MLK
  print(maturity_length_key)

     # Filter and print the Maturity-Length Key (MLK) for Trip x in Year y
    mlk_trip_x_y <- maturity_length_key[Sampling_type==2 & Year== 2004 &Trip ==15 & Station == ]

     # View the filtered MLK
     print(mlk_trip_x_y)

  ## MLK
  fwrite(maturity_length_key, "herring_MLK.csv")

## Read in the data files
herring_MLK <- fread("herring_MLK.csv")

#### -------- Add data with length information  ---------  ####

## Read in the data files

herr_type2Length <- fread("Commercial Samples Herring_L_Typ_2 _1992_2024.csv") # Bias 1995-2024
herr_type3Length <- fread("Commercial Samples Herring (L)Typ 3 2020-2024.csv") # Spras 2020-2024
herr_type4Length <- fread("Commercial Samples Herring (L)Typ 4 1992-2022.csv") # Commercial 1992-2022
herr_type7Length <- fread("Commercial Samples Herring (L)Typ 7 2020-2024.csv") # Provtagning pelagisk fisk 2020-2024
herr_type8Length <- fread("Commercial Samples Herring (L)Typ 8 1993-2020.csv") # Industrifisk 1993-2020
herr_type16Length <- fread("Commercial Samples Herring (L)Typ 16 2024.csv")# RU-SPRAS 2024  

  ## check number of rows and columns
  dim(herr_type2Length)
  dim(herr_type3Length)
  dim(herr_type4Length)  
  dim(herr_type7Length)     
  dim(herr_type8Length)
  dim(herr_type16Length)

## Combine the data tables
herr_length_data <- rbind(herr_type2Length, herr_type3Length, herr_type4Length, herr_type7Length, herr_type8Length, herr_type16Length)
dim(herr_length_data)

##save length data
fwrite(herr_length_data, "herring_length_data.csv")


#####-----  Raise maturity from MLK per length class in herr_length_data using data.table-----#####

# Load the Maturity-Length Key (MLK) data
herring_MLK <- fread("herring_MLK.csv")
# Load the herr_length_data data
herring_length_data <- fread("herring_length_data.csv") 

# Merge MLK proportions with herr_length_data on common columns using data.table
setDT(herring_length_data)
setDT(herring_MLK)


###############Here we go############## 

# Perform the merge
herr_length_data_with_mat <- herring_MLK[herr_length_data, on = .(Sampling_type, Year, Trip, Station, Lengthclass_mm)]

# View the merged data
print(head(herr_length_data))

# Save the updated herr_length_data with maturity proportions
fwrite(herr_length_data, "herr_length_data_with_maturity.csv")














############--------Explore data coverage -------##########
## Create pivot table with counts, sums, and means of Maturity_Binary per Maturity_Final
pivot_table <- herr_fixed[, .(
  Count = .N,  # Total number of rows
  Sum_Binary = sum(Maturity_Binary, na.rm = TRUE),  # Sum of Maturity_Binary
  Mean_Binary = mean(Maturity_Binary, na.rm = TRUE)  # Mean of Maturity_Binary
), by = Maturity_Final]

# Pivot table with counts of 0 and 1 in Maturity_Binary per Lengthclass
binary_pivot <- herr_fixed[, .(
  Count_0 = sum(Maturity_Binary == 0, na.rm = TRUE),  # Count of 0s
  Count_1 = sum(Maturity_Binary == 1, na.rm = TRUE)   # Count of 1s
), by = Lengthclass_mm]

    # Order the result by Lengthclass
    setorder(binary_pivot, Lengthclass_mm)

    # View the result
    print(binary_pivot)

# Calculate unique stations and trips per year
unique_stations_trips <- mat_code[, .(
  unique_stations = uniqueN(Station),
  unique_trips = uniqueN(Trip)
), by = Year]

# View the result
print(unique_stations_trips)

# Create a table showing the number of stations by year and trip

stations_count_table <- mat_code[, .(num_stations = uniqueN(Station)), by = .(Year, Trip)]

# View the result
print(stations_count_table)

# Check if the same trip numbers (names) occur in several years

trip_years <- mat_code[, .(years = unique(Year)), by = Station]

# Identify trips that occur in multiple years
trips_in_multiple_years <- trip_years[, .N, by = Station][N > 1]

# View the result
print(trips_in_multiple_years)

# Filter and print the Maturity-Length Key (MLK) for Trip 59 in Year 1995
mlk_trip_59_1995 <- maturity_length_key[Trip == 9 & Station == 22 & Year == 2000]

# View the filtered MLK
print(mlk_trip_59_1995)

# Calculate maturity from MLK per length class in herr_length_data
maturity_by_length <- herr_length_data[, .(
  Proportion_Mature = sum(Maturity_Binary == 1, na.rm = TRUE) / .N  # Proportion of mature individuals
), by = .(Lengthclass_mm)]

# Order the result by Lengthclass_mm
setorder(maturity_by_length, Lengthclass_mm)

# View the result
print(maturity_by_length)

# Save the result to a CSV file
fwrite(maturity_by_length, "maturity_by_length.csv")
