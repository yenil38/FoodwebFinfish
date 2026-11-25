# Gulf of California food web: Figures López Herrera et al. 2026
# Purpose: Generate study area map
# Figure script revision: Dora Liney López Herrera

# ==========================================================================
# FIGURE 1A. STUDY AREA MAP
# ==========================================================================

# --------------------------------------------------------------------------
# 1. Country and state boundaries
# --------------------------------------------------------------------------

world <- rnaturalearth::ne_countries(
  scale = "large",
  returnclass = "sf"
)

mex <- world[world$admin == "Mexico", ]

usa <- world[
  world$admin == "United States of America",
]

states <- rnaturalearth::ne_states(
  country = "Mexico",
  returnclass = "sf"
)

gulf_states <- states[
  states$name %in% c(
    "Baja California",
    "Baja California Sur",
    "Sonora",
    "Sinaloa"
  ),
]

# --------------------------------------------------------------------------
# 2. Study-area extent
# --------------------------------------------------------------------------

study_bbox <- st_bbox(
  c(
    xmin = -117,
    xmax = -105,
    ymin = 20,
    ymax = 32
  ),
  crs = st_crs(4326)
)

# --------------------------------------------------------------------------
# 3. Crop spatial data
# --------------------------------------------------------------------------

mex_crop <- st_crop(
  mex,
  study_bbox
)

usa_crop <- st_crop(
  usa,
  study_bbox
)

gulf_states_crop <- st_crop(
  gulf_states,
  study_bbox
)

# --------------------------------------------------------------------------
# 4. Projection
# --------------------------------------------------------------------------

crs_proj <- 6372

mex_crop <- st_transform(
  mex_crop,
  crs_proj
)

usa_crop <- st_transform(
  usa_crop,
  crs_proj
)

gulf_states_crop <- st_transform(
  gulf_states_crop,
  crs_proj
)

study_bbox_sf <- st_as_sfc(
  study_bbox
) %>%
  st_transform(crs_proj)

study_bbox_proj <- st_bbox(
  study_bbox_sf
)

# --------------------------------------------------------------------------
# 5. Gulf of California label
# --------------------------------------------------------------------------

label_point <- st_sfc(
  st_point(c(-110.5, 26)),
  crs = 4326
) %>%
  st_transform(crs_proj)

label_coords <- st_coordinates(
  label_point
)

# --------------------------------------------------------------------------
# 6. Study-area map
# --------------------------------------------------------------------------

map_gc <- ggplot() +
  
  # Country fill
  geom_sf(
    data = usa_crop,
    fill = "grey70",
    color = NA
  ) +
  
  geom_sf(
    data = mex_crop,
    fill = "grey60",
    color = NA
  ) +
  
  # State boundaries
  geom_sf(
    data = gulf_states_crop,
    fill = NA,
    color = "grey30",
    linewidth = 0.2,
    linetype = "dashed"
  ) +
  
  # Country boundaries
  geom_sf(
    data = usa_crop,
    fill = NA,
    color = "black",
    linewidth = 0.25
  ) +
  
  geom_sf(
    data = mex_crop,
    fill = NA,
    color = "black",
    linewidth = 0.3
  ) +
  
  # Map extent
  coord_sf(
    xlim = study_bbox_proj[c("xmin", "xmax")],
    ylim = study_bbox_proj[c("ymin", "ymax")],
    expand = FALSE
  ) +
  
  # Scale bar
  ggspatial::annotation_scale(
    location = "bl",
    width_hint = 0.25,
    text_cex = 0.6
  ) +
  
  # Gulf of California label
  annotate(
    "text",
    x = label_coords[1],
    y = label_coords[2],
    label = "Gulf of California",
    size = 4,
    angle = -55,
    family = "Times",
    fontface = "italic"
  ) +
  
  labs(
    x = NULL,
    y = NULL
  ) +
  
  theme_bw() +
  
  theme(
    
    text = element_text(
      family = "Times"
    ),
    
    panel.background = element_rect(
      fill = "grey95"
    ),
    
    panel.grid.major = element_line(
      color = "grey85",
      linewidth = 0.2
    ),
    
    panel.grid.minor = element_blank(),
    
    panel.border = element_rect(
      color = "black",
      fill = NA,
      linewidth = 1
    ),
    
    axis.text = element_text(
      size = 7
    ),
    
    axis.title = element_blank(),
    
    legend.position = "none"
  )

# Visualizar
map_gc

ggsave(
  "Map/Figure_1A_Study_Area.pdf",
  plot = map_gc,
  width = 18,
  height = 14,
  units = "cm"
)

ggsave(
  "Map/Figure_1A_Study_Area.tiff",
  plot = map_gc,
  width = 18,
  height = 14,
  units = "cm",
  dpi = 600,
  compression = "lzw"
)

# ==========================================================================
# FIGURE 1B. NORTH AMERICA INSET
# ==========================================================================

# --------------------------------------------------------------------------
# 1. North America
# --------------------------------------------------------------------------

north_america <- rnaturalearth::ne_countries(
  continent = "North America",
  scale = "large",
  returnclass = "sf"
)

# --------------------------------------------------------------------------
# 2. Remove internal political boundaries
# --------------------------------------------------------------------------

north_america_union <- st_union(
  north_america
)

north_america_boundary <- st_boundary(
  north_america_union
)

# --------------------------------------------------------------------------
# 3. Study-area extent
# --------------------------------------------------------------------------

study_extent_inset <- st_transform(
  st_as_sfc(study_bbox),
  st_crs(north_america_union)
)

# --------------------------------------------------------------------------
# 4. North America inset
# --------------------------------------------------------------------------

inset_na <- ggplot() +
  
  # North America
  geom_sf(
    data = north_america_union,
    fill = "grey80",
    color = NA
  ) +
  
  # Continental outline
  geom_sf(
    data = north_america_boundary,
    color = "black",
    linewidth = 0.25
  ) +
  
  # Study-area rectangle
  geom_sf(
    data = study_extent_inset,
    fill = NA,
    color = "black",
    linewidth = 0.35
  ) +
  
  theme_void() +
  
  theme(
    panel.border = element_blank()
  )

# Visualizar
inset_na

ggsave(
  "Map/Figure_1B_North_America_Inset.pdf",
  plot = inset_na,
  width = 8,
  height = 6,
  units = "cm"
)

ggsave(
  "Map/Figure_1B_North_America_Inset.tiff",
  plot = inset_na,
  width = 8,
  height = 6,
  units = "cm",
  dpi = 600,
  compression = "lzw"
)

# ==========================================================================
# FIGURE 1C. STUDY AREA + NORTH AMERICA INSET
# ==========================================================================

figure1 <- cowplot::ggdraw() +
  
  # Main study-area map
  cowplot::draw_plot(
    map_gc,
    x = 0,
    y = 0,
    width = 1,
    height = 1
  ) +
  
  # North America inset
  cowplot::draw_plot(
    inset_na,
    x = 0.63,
    y = 0.73,
    width = 0.29,
    height = 0.29
  )

# Visualizar
figure1