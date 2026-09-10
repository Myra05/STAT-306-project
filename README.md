# Housing Prices in Metro Vancouver
A statistical modeling project investigating the relationship between housing prices, family income, interest rates, and housing type in Metro Vancouver using quarterly data from 2000–2025.

## Overview
This project explores factors associated with median housing prices in Metro Vancouver using publicly available data from the B.C. Data Catalogue. We investigated how family income and the prime interest rate are associated with housing prices while accounting for differences between housing types.

After exploratory data analysis and assessment of multicollinearity, we developed and evaluated multiple linear regression models using a log transformation of median housing price. Model selection was used to identify a parsimonious model that maintained strong explanatory power while avoiding unnecessary predictors.

## Methods
1. **Data cleaning & wrangling**
   - Filtered the B.C. housing affordability dataset to Metro Vancouver
   - Cleaned variable names and checked for missing values and duplicates
   - Scaled income and resale variables to improve interpretability

2. **Exploratory data analysis**
   - Examined summary statistics and housing price distributions
   - Visualized housing price trends across housing types from 2000–2025
   - Investigated correlations between explanatory variables
   - Applied a log transformation to median housing price to reduce right skewness

3. **Statistical modeling**
   - Built multiple linear regression models with `log(median_housing_price)` as the response
   - Assessed multicollinearity using Variance Inflation Factors (VIF)
   - Removed highly collinear predictors and variables derived directly from the response
   - Compared candidate models using Adjusted $R^2$ and Mallows' $C_p$

4. **Model diagnostics**
   - Examined residual plots
   - Assessed linearity, constant variance, and residual patterns
   - Checked for remaining multicollinearity in the final model

## Key Findings
- The final model explained approximately **95.5% of the variation in log median housing prices**.
- **Family income and prime interest rate were both significantly associated with housing prices**, after accounting for housing type.
- A $10,000 increase in median after-tax family income was associated with approximately a **32% increase in median housing price**, holding other predictors constant.
- A 1 percentage-point increase in the prime interest rate was associated with approximately a **2.8% decrease in median housing price**, holding other predictors constant.
- Housing type was strongly associated with price, with single-detached homes having substantially higher prices than the reference housing category.
- The final model included only **housing type, family income, and prime interest rate**. Adding quarter or number of resales provided almost no improvement in explanatory power.
- The selected model achieved an **Adjusted $R^2$ of 0.954** while maintaining low multicollinearity among its predictors.

## Dataset
The analysis uses the **Housing Affordability for New Homeowners in B.C., Census Metropolitan Areas Quarterly Data 2025 Q3** dataset from the B.C. Data Catalogue.

The dataset contains quarterly observations from 2000–2025 and includes:
- Median housing price
- Median after-tax family income
- Prime interest rate
- Mortgage payment as a percentage of income
- Historic payment percentage of income
- Number of resales
- Housing type
- Year and quarter

## Tools & Technologies
- R
- tidyverse
- ggplot2
- Multiple Linear Regression
- Log transformations
- Variance Inflation Factor (VIF)
- Mallows' $C_p$
- Adjusted $R^2$
- Model diagnostics

## Authors

**UBC STAT 306 — Group Project**
