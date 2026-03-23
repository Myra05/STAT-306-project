library(janitor)
library(tidyverse)

# read in data
data = read.csv("bc-data-catalogue-cma-2025-q3.csv")
head(data)
glimpse(data)

# filter for Metro Van
vancouver_data <- data |>
  filter(CMA.NAME == "Vancouver") |>
  clean_names()

head(vancouver_data)

# EDA
summary(vancouver_data)

# Visualizations
#Correlation heatmap of all numeric variables
corr_matrix <- vancouver_data |>
  select(where(is.numeric), -cma_id, -median_housing_price) |>
  cor() |>
  as_tibble(rownames = 'var1') |>
  pivot_longer(-var1, names_to = "var2", values_to = "corr")

options(repr.plot.width = 10, repr.plot.height = 9)

heatmap_van <- corr_matrix |>
  ggplot(aes(var1, var2, fill= corr)) +
  geom_tile(color = "white") +
  scale_fill_distiller(
    palette = "YlOrRd",
    direction = 1, 
    limits = c(-1, 1)
  ) +
  labs(title = "Correlation coefficients between numeric explanatory variables", x = "", y = "") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1),
    axis.text.y = element_text(vjust = 1, size = 12, hjust = 1),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 12),
    legend.key.size = unit(1.5, "cm")) + 
  coord_fixed() +
  geom_text(aes(var2, var1, label = round(corr, 2)), color = "black", size = 4.5)

heatmap_van

#Time trend
line_plot = ggplot(vancouver_data, aes(x = year, y = median_housing_price, color = housing_type)) +
  geom_line(linewidth = 1) +
  geom_point(alpha = 0.5) +
  theme_minimal() +
  labs(title = "Housing Prices Over Time")
options(repr.plot.width = 8, repr.plot.height = 5)
line_plot

#log-transformed distribution
ggplot(vancouver_data, aes(x = log(median_housing_price))) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  scale_x_continuous(labels = scales::comma) +
  theme_minimal() +
  labs(
    title = "Distribution of Median Housing Prices",
    x = "Median Housing Price (Log scale)",
    y = "Frequency"
  )
options(repr.plot.width = 6, repr.plot.height = 4)

# Statistical analysis
