library(janitor, quietly = T)
library(tidyverse, quietly = T)
library(car, quietly = T)
library(broom, quietly = T)

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
## summary statistics
summary(vancouver_data)

## Visualizations
#Correlation heatmap of all numeric explanatory variables
corr_matrix <- vancouver_data |>
  select(where(is.numeric), -cma_id, -median_housing_price) |>
  cor() |>
  as_tibble(rownames = 'var1') |>
  pivot_longer(-var1, names_to = "var2", values_to = "corr")

options(repr.plot.width = 10, repr.plot.height = 9)

heatmap_van <- corr_matrix |>
  ggplot(aes(var1, var2, fill= corr)) +
  geom_tile(color = "white") +
  scale_fill_distiller(palette = "YlOrRd", direction = 1,  limits = c(-1, 1)) +
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
  scale_y_continuous(labels = scales::label_dollar()) +
  theme_minimal() +
  labs(title = "Housing Prices Over Time")
options(repr.plot.width = 8, repr.plot.height = 5)
line_plot

#log-transformed distribution
ggplot(vancouver_data, aes(x = median_housing_price)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  scale_x_log10(labels = scales::label_dollar()) +
  theme_minimal() +
  labs(
    title = "Distribution of Median Housing Prices",
    x = "Median Housing Price (Log scale)",
    y = "Frequency"
  )
options(repr.plot.width = 6, repr.plot.height = 4)

# Statistical analysis
vancouver_data <- vancouver_data |>
  mutate(income_10k = median_after_tax_annual_family_income / 10000,
         resales_100 = number_of_resales / 100)
head(vancouver_data)

# model selection
full_model <- lm(log(median_housing_price) ~ 
                   year + quarter + housing_type + prime_interest_rate + income_10k + 
                   mortgage_payment_percent_income + historic_payment_percent_income + resales_100, data = vancouver_data)
alias(full_model)

noalias_model <- lm(log(median_housing_price) ~ 
                      year + quarter + housing_type + prime_interest_rate + income_10k + 
                      mortgage_payment_percent_income + resales_100, data = vancouver_data)
vif(noalias_model)

vif_model <- lm(log(median_housing_price) ~ 
                  housing_type + income_10k + quarter+
                  prime_interest_rate + resales_100, data = vancouver_data)
vif(vif_model)

m1 <- lm(log(median_housing_price) ~ housing_type + income_10k + prime_interest_rate, data = vancouver_data)
m2 <- lm(log(median_housing_price) ~ housing_type + income_10k + prime_interest_rate + resales_100, data = vancouver_data)
m3 <- lm(log(median_housing_price) ~ housing_type + income_10k + prime_interest_rate + quarter, data = vancouver_data)
m4 <- lm(log(median_housing_price) ~ housing_type + income_10k + prime_interest_rate + resales_100 + quarter, data = vancouver_data)

n <- nrow(vancouver_data)
q <- 5

ssres_base <- deviance(m1)
ssres_resales <- deviance(m2)
ssres_quarter <- deviance(m3)
ssres_full <- deviance(m4)

ssres_values <- c(ssres_base, ssres_resales, ssres_quarter, ssres_full)
p_covariates <- c(3, 4, 4, 5)
full_model <- lm(log(median_housing_price) ~ housing_type + income_10k + prime_interest_rate + resales_100 + quarter, data = vancouver_data)
mse_full <- deviance(full_model) / full_model$df.residual

p_params <- c(length(coef(m1)), length(coef(m2)), length(coef(m3)), length(coef(m4)))
Cps <- ssres_values / mse_full - (n - 2 * p_params)

tibble(p_params = p_params,
       SSRes = round(ssres_values, 4),
       Cp = round(Cps, 2),
       Adj_R2 = c(summary(m1)$adj.r.squared, summary(m2)$adj.r.squared, 
                  summary(m3)$adj.r.squared, summary(m4)$adj.r.squared))


model <- lm(log(median_housing_price) ~ housing_type + income_10k + prime_interest_rate, data = vancouver_data)
vif(model)

par(mfrow = c(2, 2))
plot(model)
par(mfrow = c(1, 1))

model_results <- tidy(model, conf.int = TRUE) |> 
  mutate(across(where(is.numeric), \(x) round(x, 7)))

print("Model Summary:")
print(model_results)

model_performance <- glance(model)
print("Model Performance (R-squared):")
print(model_performance$adj.r.squared)

par(mfrow = c(2, 2))

plot(vancouver_data$income_10k, resid(model),
     xlab = "Income (10k units)",
     ylab = "Residuals",
     main = "Residuals vs Income")
abline(h = 0, lty = 2)
lines(lowess(vancouver_data$income_10k, resid(model)), lwd = 2)

plot(vancouver_data$prime_interest_rate, resid(model),
     xlab = "Prime interest rate",
     ylab = "Residuals",
     main = "Residuals vs Prime Interest Rate")
abline(h = 0, lty = 2)
lines(lowess(vancouver_data$prime_interest_rate, resid(model)), lwd = 2)

boxplot(resid(model) ~ vancouver_data$housing_type,
        xlab = "Housing type",
        ylab = "Residuals",
        main = "Residuals vs Housing Type")
abline(h = 0, lty = 2)

plot.new()

par(mfrow = c(1, 1))

ord <- order(vancouver_data$year, vancouver_data$quarter)

plot(resid(model)[ord], type = "b",
     xlab = "Time order",
     ylab = "Residuals",
     main = "Sequential Residuals")
abline(h = 0, lty = 2)