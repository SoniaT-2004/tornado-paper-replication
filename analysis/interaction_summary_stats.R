library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)
library(readr)
library(kableExtra)
library(scales)
library(gt) 
df <- read_csv("/Users/soniatao/Desktop/Tornado/nov19/full_panel_nov19.csv")
# df <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_control_mxier_tx_cleaned.csv")
# df <- read_csv("/Users/soniatao/Desktop/Tornado/treated/tornado_exposed_mxier_tx_cleaned.csv")
# df <- read_csv("/Users/soniatao/Desktop/Tornado/exposed_new_cleaned.csv")
# df <- read_csv("/Users/soniatao/Desktop/Tornado/nonexposed_new_cleaned.csv")

summary_stats <- df %>%
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

summary_stats %>%
  kable(caption = "Summary Statistics (Full Panel)") %>%
  kable_styling(full_width = FALSE)



# get trend and plot
trend_bimonth <- df %>%
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

# 查看表格
trend_bimonth %>% kable() %>% kable_styling()

# 主图：总交互次数随时间变化
p1 <- ggplot(trend_bimonth, aes(x = bimonth)) +
  geom_line(aes(y = total_interactions), color = "steelblue", size = 1) +
  geom_point(aes(y = total_interactions), color = "steelblue") +
  geom_vline(xintercept = as.Date("2022-08-08"), 
             linetype = "dashed", color = "red", size = 0.8) +
  annotate("text", x = as.Date("2022-08-08"), y = max(trend_bimonth$total_interactions)*0.9,
           label = "TC Sanction", color = "red", angle = 90, vjust = -0.5) +
  labs(
    # title = "Total Interactions with Mixers (Bi-monthly)",
    # subtitle = "Treated Users",
    x = "Bi-month", y = "Total #Interactions",
    caption = "Vertical line: OFAC sanctions on Tornado Cash (2022-08-08)"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

print(p1)
