# Gulf of California food web: Modularity analysis
# Purpose: Calculate node-level modularity metrics and topological roles
# Author: Tomas I. Marina (2025)
# Script revision: Dora Liney López Herrera

# Load packages 
library(igraph)
library(multiweb)
library(tidyverse)

# Load network and node-level data 
load("Results/Network_Node_GC.rda")

Red_GC <- igraph::upgrade_graph(Red_GC)

# Calculate topological roles 
top.role <- multiweb::calc_topological_roles(
  Red_GC,
  nsim = 1000,
  ncores = 4
)

# Classify topological roles 
clas.role <- multiweb::classify_topological_roles(
  top.role,
  Red_GC
)

# Extract z, PC and topological role 
top.role.df <- clas.role$hub_conn %>%
  dplyr::rename(
    TrophicSpecies = node_name,
    z = within_module_degree,
    PC = among_module_conn,
    TopRole = type
  ) %>%
  dplyr::select(
    TrophicSpecies,
    z,
    PC,
    TopRole
  )

# Add modularity metrics to node-level dataset 
m_spp_total <- m_spp_total %>%
  dplyr::left_join(
    top.role.df,
    by = "TrophicSpecies"
  )

# Save node-level results 
readr::write_csv(m_spp_total, "Results/node_properties_GC.csv")

# Summarize topological roles 
top.role.count <- top.role.df %>%
  dplyr::count(
    TopRole,
    name = "N"
  ) %>%
  dplyr::mutate(
    Percentage = round(N / sum(N) * 100, 2)
  )

readr::write_csv(
  top.role.count,
  "Results/topological_roles_GC.csv"
)

# Save modularity analysis objects 
save(
  Red_GC,
  top.role,
  clas.role,
  top.role.df,
  top.role.count,
  m_spp_total,
  file = "Results/Modularity_GC.rda"
)