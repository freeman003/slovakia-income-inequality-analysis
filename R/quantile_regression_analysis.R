# ============================================================
# Income Inequality Analysis in Slovakia
# Quantile Regression using EU-SILC 2020
#
# Author: Volodymyr Yavdoshniak
# Purpose:
# Examine how age, gender, education, and housing tenure
# are associated with equivalized disposable household income
# across different parts of the income distribution.
# ============================================================


# 1. Load required libraries
library(readxl)
library(dplyr)
library(quantreg)
library(ggplot2)
library(tidyr)
library(broom)
library(writexl)


# 2. Load EU-SILC 2020 data
# Note: The original EU-SILC microdata are not included
# in this repository.
data <- read_excel("2020.xlsx")


# 3. Data preparation
data <- data %>%
  mutate(
    # Calculate respondent age
    age = 2020 - `Rok narodenia`,

    # Convert gender to categorical variable
    gender = factor(Pohlavie),

    # Recode education levels into three broad categories
    education_grouped = case_when(
      Vzdelanie %in% c(0, 100, 200) ~ "Primary",
      Vzdelanie %in% c(300, 344, 352, 353, 354, 400, 450) ~ "Secondary",
      Vzdelanie %in% c(500, 600, 700, 800) ~ "Higher",
      TRUE ~ NA_character_
    ),

    education_grouped = factor(
      education_grouped,
      levels = c("Primary", "Secondary", "Higher")
    ),

    # Housing tenure status
    ownership = factor(`Vlastnicky status`),

    # Equivalized disposable household income
    income = EQ_INC20.x
  ) %>%
  filter(!is.na(education_grouped))


# 4. Validate categorical variables
factor_vars <- c("gender", "education_grouped", "ownership")

valid_factors <- sapply(
  data[factor_vars],
  function(x) length(unique(x)) > 1
)

included_factors <- names(valid_factors[valid_factors])


# 5. Define quantile regression formula
formula_qr <- as.formula(
  paste(
    "income ~ age +",
    paste(included_factors, collapse = " + ")
  )
)


# 6. Define quantiles
taus <- seq(0.1, 0.9, by = 0.1)


# 7. Estimate quantile regression models
models_qr <- lapply(
  taus,
  function(tau) {
    rq(
      formula_qr,
      data = data,
      tau = tau
    )
  }
)


# 8. Display model summaries
# Bootstrap standard errors are used for statistical inference.
for (i in seq_along(taus)) {

  cat("Quantile:", taus[i], "\n")

  print(
    summary(
      models_qr[[i]],
      se = "boot"
    )
  )

  cat("\n=============================\n")
}


# 9. Create coefficient table
coef_matrix <- sapply(
  models_qr,
  coef
)

coef_df <- as.data.frame(
  t(coef_matrix)
)

coef_df$tau <- taus

print(coef_df)


# 10. Median quantile regression diagnostics
median_model <- models_qr[[5]]

residuals_median <- resid(
  median_model
)

fitted_vals <- fitted(
  median_model
)


# Histogram of residuals
hist(
  residuals_median,
  main = "Residual Distribution - Median Quantile Regression",
  xlab = "Residuals"
)


# Residuals vs fitted values
plot(
  fitted_vals,
  residuals_median,
  main = "Residuals vs Fitted Values - Median Quantile Regression",
  xlab = "Fitted Values",
  ylab = "Residuals"
)

abline(
  h = 0,
  lty = 2
)


# 11. Extract detailed model results
results_list <- lapply(
  seq_along(taus),
  function(i) {

    model <- models_qr[[i]]

    tau_val <- taus[i]

    tidy_model <- broom::tidy(
      model
    )

    tidy_model$tau <- tau_val

    return(
      tidy_model
    )
  }
)


# 12. Combine results into one table
results_all <- bind_rows(
  results_list
)

results_all <- results_all %>%
  select(
    tau,
    term,
    estimate,
    statistic,
    p.value
  )


# 13. Export results
write.csv(
  coef_df,
  file = "quantile_regression_coefficients.csv",
  row.names = FALSE
)

write.csv(
  results_all,
  file = "quantile_regression_results_detailed.csv",
  row.names = FALSE
)

write_xlsx(
  results_all,
  "quantile_regression_results_detailed.xlsx"
)
