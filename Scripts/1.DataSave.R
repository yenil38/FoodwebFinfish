# Gulf of California food web: Data preparation and quality control
# Purpose: Prepare trophic interaction and node-attribute data for network analysis
# Author: Tomas I. Marina (2025)
# Data preparation and script revision: Dora Liney López Herrera

# Load packages
library(tidyverse)
library(janitor)

# Load data # Raw database containing predator-prey interactions and reference information. 
fwGC_raw <- read.csv("Data/Red_GC.csv",  header = TRUE,  fileEncoding = "Windows-1252")

# Check duplicated interactions # Identify repeated Prey-Predator pairs in the raw interaction database.
fwGC_dup <- fwGC_raw %>% 
  janitor::get_dupes(Prey, Predator)
fwGC_df <- fwGC_raw %>% 
  dplyr::select(Prey, Predator, Reference_link) %>% 
  distinct()

# Load node attribute table # Species list containing the identity and taxonomic attributes associated with each trophic species/node. 
sp_list <- read.csv("Data/Spp_list.csv",  header = TRUE,  fileEncoding = "Windows-1252")

# Save data # Save the cleaned interaction database and node-attribute table as an RData object for use in subsequent network analyses.
save(fwGC_df,  sp_list,  file = "Data/RedGC.rda")