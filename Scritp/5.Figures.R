# Gulf of California food web: Figures López Herrera et al. 2026
# Purpose: Generate publication-ready figures for the manuscript
# Author: Tomas I. Marina (2025)
# Figure script revision: Dora Liney López Herrera

# Packages ----------------------------------------------------------------
library(ggplot2)
library(igraph)
library(multiweb)
library(NetworkExtinction)
library(network)
library(dplyr)
library(ggrepel)
library(quantreg)

# Load data ----------------------------------------------------------------
load("Results/Network_Node_GC.rda")
load("Results/Keystone_Quantile_GC.rda")

# ==========================================================================
# FIGURE 2. GULF OF CALIFORNIA FOOD WEB
# ==========================================================================

# Marine finfish scale species are highlighted in gold.
# All other nodes are shown in grey.

node_colors <- ifelse(
  V(Red_GC)$Tax_group == "EscamaMar",
  "gold",
  "grey80"
)

set.seed(1)

# PDF ----------------------------------------------------------------------

cairo_pdf(
  "Figures/Figure_2_Food_web.pdf",
  width = 8,
  height = 6
)

multiweb::plot_troph_level(
  Red_GC,
  vertexLabel = FALSE,
  vertex.size = 8,
  vertex.color = node_colors,
  edge.arrow.size = 0.067,
  edge.width = 0.5,
  ylab = "Trophic level"
)

dev.off()


# TIFF ---------------------------------------------------------------------

tiff(
  "Figures/Figure_2_Food_web.tiff",
  width = 8,
  height = 6,
  units = "in",
  res = 600,
  compression = "lzw",
  type = "cairo"
)

multiweb::plot_troph_level(
  Red_GC,
  vertexLabel = FALSE,
  vertex.size = 8,
  vertex.color = node_colors,
  edge.arrow.size = 0.067,
  edge.width = 0.5,
  ylab = "Trophic level"
)

dev.off()

# ==========================================================================
# FIGURE 3. TOPOLOGICAL ROLES
# ==========================================================================

# m_spp_total already contains z, PC, and topological role classification
# calculated in Script 03.

# Create species classification table from the food-web object ------------

tax_group_df <- data.frame(
  TrophicSpecies = V(Red_GC)$name,
  Tax_group = V(Red_GC)$Tax_group
)

# Add Tax_group to key_ind -----------------------------------------------

top_role_plot_df <- key_ind %>%
  dplyr::left_join(
    tax_group_df,
    by = "TrophicSpecies"
  ) %>%
  dplyr::filter(
    !is.na(z),
    !is.na(PC),
    !is.na(TopRole)
  )

# Verify that the classification was matched -----------------------------

sum(is.na(top_role_plot_df$Tax_group))

# Topological role plot ----------------------------------------------------

figure3 <- ggplot(
  top_role_plot_df,
  aes(
    x = PC,
    y = z,
    color = TopRole
  )
) +
  
  geom_point(
    size = 2
  ) +
  
  # Thresholds separating the conventional topological roles
  
  geom_vline(
    xintercept = 0.625,
    linetype = "dashed",
    linewidth = 0.25
  ) +
  
  geom_hline(
    yintercept = 2.5,
    linetype = "dashed",
    linewidth = 0.25
  ) +
  
  # Labels restricted to marine finfish scale species
  
  ggrepel::geom_text_repel(
    data = subset(
      top_role_plot_df,
      Tax_group == "EscamaMar"
    ),
    aes(
      label = TrophicSpecies
    ),
    size = 3,
    box.padding = 0.3,
    point.padding = 0.2,
    max.overlaps = Inf,
    show.legend = FALSE
  ) +
  
  labs(
    x = "Participation coefficient (PC)",
    y = "Within-module degree (z)",
    color = "Topological role"
  ) +
  
  coord_cartesian(
    ylim = c(-1.5, 4)
  ) +
  
  theme_classic(
    base_size = 11
  ) +
  
  theme(
    text = element_text(
      family = "Times"
    ),
    axis.text = element_text(
      size = 10
    ),
    axis.title = element_text(
      size = 11
    ),
    legend.title = element_text(
      size = 10
    ),
    legend.text = element_text(
      size = 9
    )
  )

figure3

# Export Figure 3 ----------------------------------------------------------

ggplot2::ggsave(
  filename = "Figures/Figure_3_Topological_roles.pdf",
  plot = figure3,
  width = 8,
  height = 6,
  units = "in",
  device = cairo_pdf
)

ggplot2::ggsave(
  filename = "Figures/Figure_3_Topological_roles.tiff",
  plot = figure3,
  width = 8,
  height = 6,
  units = "in",
  dpi = 600,
  compression = "lzw",
  device = "tiff"
)

# ==========================================================================
# FIGURE 4. DEGREE DISTRIBUTION
# ==========================================================================

# Calculate the cumulative degree distribution and fit probabilistic
# models using NetworkExtinction.

Red_GC <- igraph::upgrade_graph(Red_GC)

g_net <- network::as.network(
  as.matrix(Red_GC)
)

degree_fit <- NetworkExtinction::DegreeDistribution(
  g_net
)


# Cumulative degree distribution ------------------------------------------

figure4 <- degree_fit[["graph"]] +
  
  labs(
    x = "Degree (k)",
    y = "Cumulative degree distribution"
  ) +
  
  theme_classic(
    base_size = 11
  ) +
  
  theme(
    text = element_text(
      family = "Times"
    ),
    axis.text = element_text(
      size = 10
    ),
    axis.title = element_text(
      size = 11
    )
  )

figure4

# Export Figure 4 ----------------------------------------------------------

ggplot2::ggsave(
  filename = "Figures/Figure_4_Degree_distribution.pdf",
  plot = figure4,
  width = 8,
  height = 6,
  units = "in",
  device = cairo_pdf
)

ggplot2::ggsave(
  filename = "Figures/Figure_4_Degree_distribution.tiff",
  plot = figure4,
  width = 8,
  height = 6,
  units = "in",
  dpi = 600,
  compression = "lzw",
  device = "tiff"
)

# ==========================================================================
# FIGURE 5. KEYSTONE INDEX VS. TROPHIC LEVEL
# ==========================================================================

# The Keystone Index and quantile regression models were calculated
# previously in Script 04. Only the fitted relationships are visualized
# here.

# Quantile regression predictions

new_TL <- data.frame(
  TL = seq(
    min(key_ind$TL, na.rm = TRUE),
    max(key_ind$TL, na.rm = TRUE),
    length.out = 200
  )
)

pred_quantiles <- dplyr::bind_rows(
  data.frame(
    TL = new_TL$TL,
    Keystone_ind = predict(rq25, newdata = new_TL),
    Quantile = "Q25"
  ),
  data.frame(
    TL = new_TL$TL,
    Keystone_ind = predict(rq50, newdata = new_TL),
    Quantile = "Q50"
  ),
  data.frame(
    TL = new_TL$TL,
    Keystone_ind = predict(rq75, newdata = new_TL),
    Quantile = "Q75"
  )
)

#------------------------------------------------
figure5 <- ggplot(
  key_ind,
  aes(x = TL, y = Keystone_ind)
) +
  
  # Observed values
  geom_point(
    size = 1.8,
    alpha = 0.6,
    color = "grey50"
  ) +
  
  # Quantile regression lines
  geom_line(
    data = pred_quantiles,
    aes(
      x = TL,
      y = Keystone_ind,
      color = Quantile,
      linetype = Quantile
    ),
    linewidth = 0.9
  ) +
  
  # Quantile labels/colors
  scale_color_manual(
    values = c(
      Q25 = "blue",
      Q50 = "black",
      Q75 = "red"
    ),
    name = "Quantile"
  ) +
  
  scale_linetype_manual(
    values = c(
      Q25 = "dashed",
      Q50 = "solid",
      Q75 = "dotted"
    ),
    name = "Quantile"
  ) +
  
  scale_x_continuous(
    breaks = seq(1, 6, 1),
    expand = expansion(mult = c(0.02, 0.02))
  ) +
  
  scale_y_reverse(
    limits = c(100, 1),
    breaks = c(seq(100, 10, by = -10), 1),
    expand = c(0, 0)
  ) +
  
  labs(
    x = "Trophic level",
    y = "Keystone Index"
  ) +
  
  theme_classic(base_size = 11) +
  theme(
    text = element_text(family = "Times"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 11),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  )

figure5

ggsave(
  "Figures/Figure_5_Keystone_Index.pdf",
  plot = figure5,
  width = 7,
  height = 6,
  units = "in",
  device = cairo_pdf
)

ggsave(
  "Figures/Figure_5_Keystone_Index.tiff",
  plot = figure5,
  width = 7,
  height = 6,
  units = "in",
  dpi = 600,
  compression = "lzw",
  device = "tiff"
)