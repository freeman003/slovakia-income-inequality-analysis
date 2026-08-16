# ============================================================
# Quantile Regression Results Visualization
# Income Inequality Analysis in Slovakia
#
# Author: Volodymyr Yavdoshniak
# ============================================================


# 1. Load required libraries
library(ggplot2)
library(dplyr)
library(readr)


# 2. Load aggregated quantile regression results
results <- read_csv("results/quantile_regression_results.csv")


# Create output directory if it does not exist
if (!dir.exists("images")) {
  dir.create("images")
}


# ============================================================
# 3. Education Effect Across Income Quantiles
# Reference category: Primary education
# ============================================================

education_data <- results %>%
  filter(variable == "Education")

education_plot <- ggplot(
  education_data,
  aes(
    x = quantile,
    y = coefficient,
    color = category,
    group = category
  )
) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.5) +
  scale_x_continuous(
    breaks = seq(0.1, 0.9, by = 0.1)
  ) +
  labs(
    title = "Education Effect Across Income Quantiles",
    subtitle = "Reference category: Primary education",
    x = "Income Quantile",
    y = "Estimated Income Difference (€)",
    color = "Education Level"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave(
  "images/education_effect.png",
  education_plot,
  width = 9,
  height = 5.5,
  dpi = 300
)


# ============================================================
# 4. Gender Income Difference Across Quantiles
# Reference category: Female
# ============================================================

gender_data <- results %>%
  filter(variable == "Gender")

gender_plot <- ggplot(
  gender_data,
  aes(
    x = quantile,
    y = coefficient
  )
) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.5) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  scale_x_continuous(
    breaks = seq(0.1, 0.9, by = 0.1)
  ) +
  labs(
    title = "Gender Income Difference Across Quantiles",
    subtitle = "Male coefficient relative to Female reference category",
    x = "Income Quantile",
    y = "Estimated Income Difference (€)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold")
  )

ggsave(
  "images/gender_income_gap.png",
  gender_plot,
  width = 9,
  height = 5.5,
  dpi = 300
)


# ============================================================
# 5. Housing Tenure Effect Across Income Quantiles
# Reference category: Outright Homeowner
# ============================================================

housing_data <- results %>%
  filter(variable == "Housing Tenure")

housing_plot <- ggplot(
  housing_data,
  aes(
    x = quantile,
    y = coefficient,
    color = category,
    group = category
  )
) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.2) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  scale_x_continuous(
    breaks = seq(0.1, 0.9, by = 0.1)
  ) +
  labs(
    title = "Housing Tenure Effect Across Income Quantiles",
    subtitle = "Reference category: Outright Homeowner",
    x = "Income Quantile",
    y = "Estimated Income Difference (€)",
    color = "Housing Tenure"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave(
  "images/housing_tenure_effect.png",
  housing_plot,
  width = 9,
  height = 5.5,
  dpi = 300
)
