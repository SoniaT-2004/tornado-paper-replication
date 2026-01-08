library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)
library(readr)
library(kableExtra)
library(scales)
library(gt) 

df1 <- read_csv("/Users/soniatao/Desktop/Tornado/exposed_new_cleaned.csv")
df2 <- read_csv("/Users/soniatao/Desktop/Tornado/nonexposed_new_cleaned.csv")

summary_stats1 <- df1 %>%
  summarise(
    `Total Observations`     = n(),
    `Distinct Users`         = n_distinct(user_wallet),
    `Time Periods`           = n_distinct(bimonth),
    `Mean Interactions`      = mean(num_interactions),
    `Median Interactions`    = median(num_interactions),
    `SD`                     = sd(num_interactions),
    `Min`                    = min(num_interactions),
    `Max`                    = max(num_interactions),
    `% Zeros`                = mean(num_interactions == 0) * 100,
    `% Positive`             = mean(num_interactions > 0) * 100,
    `Total Interactions`     = sum(num_interactions)
  ) %>%
  mutate(across(where(is.numeric), ~round(., 3)))

summary_stats1 %>%
  kable(caption = "Summary Statistics (Treated Users)") %>%
  kable_styling(full_width = FALSE)

summary_stats2 <- df2 %>%
  summarise(
    `Total Observations`     = n(),
    `Distinct Users`         = n_distinct(user_wallet),
    `Time Periods`           = n_distinct(bimonth),
    `Mean Interactions`      = mean(num_interactions),
    `Median Interactions`    = median(num_interactions),
    `SD`                     = sd(num_interactions),
    `Min`                    = min(num_interactions),
    `Max`                    = max(num_interactions),
    `% Zeros`                = mean(num_interactions == 0) * 100,
    `% Positive`             = mean(num_interactions > 0) * 100,
    `Total Interactions`     = sum(num_interactions)
  ) %>%
  mutate(across(where(is.numeric), ~round(., 3)))

summary_stats2 %>%
  kable(caption = "Summary Statistics (Untreated Users)") %>%
  kable_styling(full_width = FALSE)

# get trend and plot
trend_bimonth1 <- df1 %>%
  group_by(bimonth) %>%
  summarise(
    total_interactions = sum(num_interactions),
    n_users_active     = sum(num_interactions > 0),
    n_users_total      = n_distinct(user_wallet),
    .groups = "drop"
  ) %>%
  mutate(
    avg_per_active_user = total_interactions / n_users_active
  )
trend_bimonth2 <- df2 %>%
  group_by(bimonth) %>%
  summarise(
    total_interactions = sum(num_interactions),
    n_users_active     = sum(num_interactions > 0),
    n_users_total      = n_distinct(user_wallet),
    .groups = "drop"
  ) %>%
  mutate(
    avg_per_active_user = total_interactions / n_users_active
  )
trend_bimonth1 %>% kable() %>% kable_styling()
trend_bimonth2 %>% kable() %>% kable_styling()

df_long <- rbind(
  cbind(trend_bimonth1, series = "Treated"),
  cbind(trend_bimonth2, series = "Untreated")
)

p1 <- ggplot(df_long, aes(x = bimonth, y = total_interactions, color = series)) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = as.Date("2022-08-08"),
             linetype = "dashed", color = "black", size = 0.8) +
  annotate("text", x = as.Date("2022-08-08"),
           y = max(df_long$total_interactions)*0.9,
           label = "", color = "red", angle = 90, vjust = -0.5) +
  theme_minimal(base_size = 12)

print(p1)
