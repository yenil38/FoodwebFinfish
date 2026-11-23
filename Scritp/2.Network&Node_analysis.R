# Gulf of California food web: network & node-level analysis
# Purpose: Calculate network-level and node-level properties of the Gulf of California food web
# Author: Tomas I. Marina (2025)
# Script revision: Dora Liney López Herrera

# Load packages 
require(igraph)
require(multiweb)
require(tidyverse)
require(NetIndices)
require(network)
require(NetworkExtinction)

# Load data 
load("Data/RedGC.rda")

# ------------------------------------------------------------------------------------------------
# 1. NETWORK CONSTRUCTION
# ------------------------------------------------------------------------------------------------
# Create the directed food-web network, direction of interactions: Prey -> Predator.
GC_fw <- fwGC_df %>%
  dplyr::select(Prey, Predator)

Red_GC <- igraph::graph_from_data_frame(
  GC_fw,
  directed = TRUE
)

# Connected & disconnected species: membership.
m_comp <- decompose(Red_GC, mode = "weak")  
comp <- as.data.frame(components(Red_GC)["membership"])
write.csv(comp, file = "Data/RedGC_comp.csv")

# --------------------------------------------------------------------------
# 2. NETWORK-LEVEL PROPERTIES
# --------------------------------------------------------------------------
# Calculate general network-level topological and trophic properties.
m_prop <- multiweb::calc_topological_indices(Red_GC)

# Add food web name.
m_prop <- m_prop %>%
  mutate(
    Name = "Gulf_California"
  )

# Save network-level properties.
write_csv(m_prop,  "Results/network_properties_GC.csv")

# --------------------------------------------------------------------------
# 3. DEGREE DISTRIBUTION
# --------------------------------------------------------------------------
# Convert the igraph object to a network object required by NetworkExtinction.
m_net <- network::as.network(as.matrix(Red_GC))

# Fit alternative models to the cumulative degree distribution.
m_dd <- NetworkExtinction::DegreeDistribution(m_net)

# Extract model comparison results.
degree_models <- m_dd$models

# The first row corresponds to the best-fitting model according to the ranking provided by DegreeDistribution().
degree_best_fit <- degree_models[1, ]

# Save the complete model comparison.
write_csv(as.data.frame(degree_models), "Results/degree_distribution_models_GC.csv")

# Save the best-fitting model.
write_csv(as.data.frame(degree_best_fit), "Results/degree_distribution_best_fit_GC.csv")

# --------------------------------------------------------------------------
# 4. NODE ATTRIBUTES
# --------------------------------------------------------------------------
# Add taxonomic information from the species list to the food web.
sp_fg <- sp_list %>%
  rename(id = Node)

df_ig <- igraph::as_data_frame(
  Red_GC,
  what = "both"
)

df_ig$vertices <- df_ig$vertices %>%
  left_join(
    sp_fg,
    by = c("name" = "id")
  )

# Reconstruct the graph including node attributes.
Red_GC <- graph_from_data_frame(
  df_ig$edges,
  directed = TRUE,
  vertices = df_ig$vertices
)

# Check available vertex attributes during script development.
vertex_attr_names(Red_GC)

# --------------------------------------------------------------------------
# 5. TROPHIC LEVEL AND OMNIVORY
# --------------------------------------------------------------------------
# Create adjacency matrix for NetIndices.
adj_mat <- as_adjacency_matrix(
  Red_GC,
  sparse = FALSE
)

# Calculate trophic level (TL) and omnivory index (OI).
tl <- TrophInd(
  as.matrix(adj_mat)
)

# Round values for reporting.
tl <- round(
  tl,
  digits = 3
)

# Save trophic metrics.
write_csv(as.data.frame(tl), "Results/trophic_level_omnivory_GC.csv")

# Add trophic metrics as vertex attributes.
V(Red_GC)$TL <- tl$TL
V(Red_GC)$Omn <- tl$OI

# --------------------------------------------------------------------------
# 6. NODE DEGREE
# --------------------------------------------------------------------------
# Calculate total degree and its directed components: In-degree (number of prey of each predator) & Out-degree (number of predators consuming each prey).
V(Red_GC)$TotalDegree <- degree(
  Red_GC,
  mode = "total"
)

V(Red_GC)$InDegree <- degree(
  Red_GC,
  mode = "in"
)

V(Red_GC)$OutDegree <- degree(
  Red_GC,
  mode = "out"
)

# --------------------------------------------------------------------------
# 7. BETWEENNESS CENTRALITY
# --------------------------------------------------------------------------
# Calculate node betweenness centrality, it´s measures the number of shortest paths between other nodes that pass through a given node.

V(Red_GC)$Betweenness <- igraph::betweenness(
  Red_GC,
  directed = TRUE,
  cutoff = -1
)

# --------------------------------------------------------------------------
# 8. NODE-LEVEL DATA TABLE
# --------------------------------------------------------------------------
# Combine trophic and topological properties into a single table.
m_spp_total <- tibble(
  ID = seq_along(V(Red_GC)),
  TrophicSpecies = V(Red_GC)$name,
  Group = V(Red_GC)$Tax_group,
  TotalDegree = V(Red_GC)$TotalDegree,
  NumPrey = V(Red_GC)$InDegree,
  NumPred = V(Red_GC)$OutDegree,
  Between = V(Red_GC)$Betweenness,
  TL = V(Red_GC)$TL,
  Omn = V(Red_GC)$Omn
)

# Save node-level properties.
write_csv(m_spp_total, "Results/node_properties_GC.csv")

# --------------------------------------------------------------------------
# 9. SAVE ANALYSIS OBJECTS
# --------------------------------------------------------------------------
# Save the network and results required by subsequent analyses.
save(
  Red_GC,
  m_prop,
  m_dd,
  degree_models,
  degree_best_fit,
  tl,
  m_spp_total,
  file = "Results/Network_Node_GC.rda"
)