# Gulf of California food web: Keystone Index and quantile regression
# Purpose: Calculate the Keystone Index (KSI) and evaluate its relationship
#          with trophic level using quantile regression
# Authors: KSI (López Herrera et al., 2026) & Quantile regression (Rodríguez & Saravia, 2024)
# Script revision: Dora Liney López Herrera

# Packages 
library(dplyr)
library(quantreg)

# Load data 
load("Results/Network_Node_GC.rda")
load("Results/Modularity_GC.rda")

# Prepare species-level properties.
all_sp_prop <- m_spp_total %>%
  dplyr::select(
    TrophicSpecies,
    Group,
    TotalDegree,
    NumPrey,
    NumPred,
    Between,
    TL,
    Omn,
    z,
    PC,
    TopRole
  )

#--------------------------------------------------------------------------
# Keystone Index (KSI)
#--------------------------------------------------------------------------
# This Index integrates five complementary node-level metrics:
# in-degree (NumPrey), out-degree (NumPred), betweenness centrality
# (Between), within-module degree (z), and participation coefficient (PC).
#
# Each metric is ranked in descending order, so species with higher
# structural importance receive lower numerical ranks.
# The KSI is the arithmetic mean of the five ranks.
#
# Therefore, lower KSI values indicate greater structural importance.

key_ind <- all_sp_prop %>%
  mutate(
    indeg_rank = dense_rank(desc(NumPrey)),
    outdeg_rank = dense_rank(desc(NumPred)),
    btw_rank = dense_rank(desc(Between)),
    withinMod_rank = dense_rank(desc(z)),
    amongMod_rank = dense_rank(desc(PC))
  ) %>%
  mutate(
    Keystone_ind = rowMeans(
      cbind(
        indeg_rank,
        outdeg_rank,
        btw_rank,
        withinMod_rank,
        amongMod_rank
      )
    ),
    Keystone_rank = dense_rank(Keystone_ind)
  )

# Save species-level KSI results 
readr::write_csv(key_ind, "Results/Keystone_Index_GC.csv")

#--------------------------------------------------------------------------
# Quantile regression
#--------------------------------------------------------------------------
# Evaluate the relationship between Keystone Index and trophic level
# at the 25th, 50th, and 75th conditional quantiles.

set.seed(123)

rq25 <- quantreg::rq(
  Keystone_ind ~ TL,
  data = key_ind,
  tau = 0.25
)

rq50 <- quantreg::rq(
  Keystone_ind ~ TL,
  data = key_ind,
  tau = 0.50
)

rq75 <- quantreg::rq(
  Keystone_ind ~ TL,
  data = key_ind,
  tau = 0.75
)

# Bootstrap inference 
# Bootstrap standard errors are used to assess the significance of the
# relationship between trophic level and Keystone Index.

s25 <- summary(
  rq25,
  se = "boot",
  R = 1000
)

s50 <- summary(
  rq50,
  se = "boot",
  R = 1000
)

s75 <- summary(
  rq75,
  se = "boot",
  R = 1000
)

# Extract regression results 

quantile_results <- data.frame(
  Quantile = c(0.25, 0.50, 0.75),
  
  Intercept = c(
    coef(rq25)[1],
    coef(rq50)[1],
    coef(rq75)[1]
  ),
  
  Beta_TL = c(
    coef(rq25)[2],
    coef(rq50)[2],
    coef(rq75)[2]
  ),
  
  SE_Beta = c(
    s25$coefficients[2, 2],
    s50$coefficients[2, 2],
    s75$coefficients[2, 2]
  ),
  
  P_value = c(
    s25$coefficients[2, 4],
    s50$coefficients[2, 4],
    s75$coefficients[2, 4]
  )
)

# Save quantile regression results 
readr::write_csv(quantile_results, "Results/Quantile_regression_GC.csv")

# Save analysis objects 
save(
  key_ind,
  rq25,
  rq50,
  rq75,
  s25,
  s50,
  s75,
  quantile_results,
  file = "Results/Keystone_Quantile_GC.rda"
)