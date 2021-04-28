#Load libraries
library(tidyverse)
library(Rmisc)

#Load in light csv. Measurements units are == light intensity (umol m-2 s-1)
df <- read_csv("Sample_Info/SWChem/20180608_light_measurements.csv")

#Calculate summary statistics to report mean and SE light measurements
stats <- summarySE(data = df, measurevar = "Light")
