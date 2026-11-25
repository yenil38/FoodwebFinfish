# FoodwebFinfish

**Structural importance of marine finfish species in the Gulf of California food web**

## Project overview

This repository contains the R scripts used to analyze the trophic structure of the Gulf of California food web, with particular emphasis on the structural importance of species classified as *marine finfish* (*escama marina*).

The analyses combine network-level and node-level topological properties, trophic metrics, modularity, and a composite Keystone Index (KSI) to characterize the ecological roles of marine finfish species within the food web.

This project aims to contribute to the understanding of food-web structure and provide information relevant to ecosystem-based fisheries management.

## Abstract

Multispecies marine finfish fisheries in coastal and shelf seas face substantial management hurdles because commercial catches are routinely aggregated into broad taxonomic categories, obscuring species-specific trophic contributions. In this study, we evaluate the structural and topological importance of marine finfish resources in the Gulf of California using complex ecological network analysis. We assembled a high-resolution food web comprising 168 nodes (165 living trophic species across 104 teleost species collapsed into 30 finfish nodes, plus three non-living compartments) and 1,647 feeding interactions. Network complexity was characterized through directed connectance and degree distribution fitting. To capture multidimensional structural importance, we developed a Key Species Index (*KSI*) integrating local connectivity (degree *k*) global centrality (betweenness *btw*), and intra- and inter-modular connectivity. The food web displayed low direct connectance (C=0.058) and an exponential degree distribution, reflecting structural resilience mediated by a majority of moderately connected taxa. While basal crustaceans and zooplankton dominated by total number of interactions (degree), commercially valuable finfish (predominantly Lutjanidae, Epinephelidae, and Carangidae) served as essential module connectors and pathway brokers. Quantile regressions revealed that structural importance significantly intensified with trophic level. These findings provide an objective topological baseline for ecosystem-based fisheries management, suggesting that finfish conservation should account for multi-tiered network roles rather than landing volume alone.

## Repository structure

The repository currently contains the following files:

```text
FoodwebFinfish/
│
├── Scripts/
│   ├── 1.DataSave.R
│   ├── 2.Network&Node_analysis.R
│   ├── 3.Modularity_analysis.R
│   ├── 4.KSI&RegrQuant.R
│   ├── 5.Figures.R
│   └── 6.Map.R
│
├── .gitignore
├── FoodwebFinfish.Rproj
└── README.md
```

The `Data/`, `Results/`, `Figures/`, and `Map/` directories are used by the scripts for input files and generated outputs. They are not included in the current public repository.

## Data availability

The input datasets used in this study are not publicly available in this repository while the associated manuscript is undergoing the publication process.

The analyses require the following input files:

- `Data/Red_GC.csv`: Predator–prey interaction database, including prey, predator, and reference information.
- `Data/Spp_list.csv`: Trophic species list containing node identifiers and taxonomic attributes.

These datasets will be provided to the journal editors for evaluation during the manuscript review process, as required.

**Note:** The R scripts are provided to document the analytical workflow. Running the complete analysis requires access to the original input datasets, which are not included in this repository.

## Analysis workflow

Run the scripts in the following order:

| Script                      | Description                                                                                                              |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `1.DataSave.R`              | Prepares and checks the predator–prey interaction database and species attribute table.                                  |
| `2.Network&Node_analysis.R` | Constructs the directed food-web network and calculates network-level and node-level topological and trophic properties. |
| `3.Modularity_analysis.R`   | Calculates modularity-related metrics and classifies species according to their topological roles.                       |
| `4.KSI&RegrQuant.R`         | Calculates the Keystone Index (KSI) and evaluates its relationship with trophic level using quantile regression.         |
| `5.Figures.R`               | Generates the food-web, topological-role, degree-distribution, and KSI figures.                                          |
| `6.Map.R`                   | Generates the study-area map and North America inset.                                                                    |

Scripts 1–4 prepare the data and perform the main analyses. Scripts 5 and 6 generate the graphical outputs.

## Main analytical methods

The repository includes the following analyses:

- Food-web construction as a directed network (prey → predator).
- Network-level topological properties.
- Cumulative degree distribution and model fitting.
- Node-level degree and betweenness centrality.
- Trophic level and omnivory index.
- Modularity and topological role classification.
- Keystone Index (KSI), integrating five complementary node-level metrics.
- Quantile regression at the 25th, 50th, and 75th conditional quantiles.

Lower KSI values indicate greater structural importance because the index is calculated as the arithmetic mean of descending metric ranks.

## Software requirements

The scripts were developed using **R version 4.5.3**.

The following R packages are required:

- `tidyverse`
- `janitor`
- `igraph`
- `multiweb`
- `NetIndices`
- `network`
- `NetworkExtinction`
- `quantreg`
- `ggplot2`
- `ggrepel`
- `sf`
- `rnaturalearth`
- `ggspatial`
- `cowplot`

Install the required packages using:

```r
packages <- c(
  "tidyverse",
  "janitor",
  "igraph",
  "multiweb",
  "NetIndices",
  "network",
  "NetworkExtinction",
  "quantreg",
  "ggplot2",
  "ggrepel",
  "sf",
  "rnaturalearth",
  "ggspatial",
  "cowplot"
)

install.packages(packages)
```

Some spatial packages may require additional system libraries depending on the operating system.

## Outputs

The scripts generate the following types of outputs:

- Cleaned food-web interaction data and species attributes.
- Network-level and node-level properties.
- Trophic level and omnivory estimates.
- Degree distribution model comparisons.
- Modularity metrics and topological role classifications.
- Keystone Index values and quantile regression results.
- Publication-quality figures in PDF and TIFF formats.
- Study-area maps in PDF and TIFF formats.

Output files are saved in the corresponding `Data/`, `Results/`, `Figures/`, and `Map/` directories.

## Authors and contributions

**Original R script author:**

Tomás I. Marina (2025).

**Script revision, adaptation, and implementation for the present study:**

Dora Liney López Herrera.

The original R scripts were reviewed, revised, and adapted for the analyses presented in this repository. Individual script headers provide additional information on authorship, methodological contributions, and specific revisions.

## Citation

Users are encouraged to acknowledge the original script author and cite this repository when reusing or modifying the code.

**Original scripts:**

Marina, T. I. (2025). Original R scripts used as the basis for the food-web analyses.

**Repository citation:**

López Herrera, D. L. (2026). *FoodwebFinfish: Structural importance of marine finfish species in the Gulf of California food web*. GitHub repository. [https://github.com/yenil38/FoodwebFinfish.git](https://github.com/yenil38/FoodwebFinfish.git)

**Associated publication:**

To be completed after publication.

## License

The license for this repository will be specified following confirmation of the terms agreed upon by the original script author and the contributor responsible for the revisions and adaptations.

Users should acknowledge the original script author, cite this repository, and cite the associated scientific publication when available.
