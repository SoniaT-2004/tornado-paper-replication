library(tidyverse)
library(lubridate)
library(scales)
library(gt)

df <- read_csv("/Users/soniatao/Desktop/Tornado/bridge_sum_full1.csv") %>%
  mutate(day = ymd(day)) %>%
  arrange(day)

glimpse(df)
summary(df$interactions)

# descriptive stats
overall_stats <- df %>%
  summarise(
    n_obs = n(),
    mean_tx = mean(interactions, na.rm = TRUE),
    median_tx = median(interactions, na.rm = TRUE),
    sd_tx = sd(interactions, na.rm = TRUE),
    Q1 = quantile(interactions, 0.25, na.rm = TRUE),
    Q3 = quantile(interactions, 0.75, na.rm = TRUE),
    min = min(interactions, na.rm = TRUE),
    max = max(interactions, na.rm = TRUE),
    total = sum(interactions, na.rm = TRUE)
  )
print(overall_stats)

# daily time series plot
ggplot(df, aes(x = day, y = interactions)) +
  geom_line(linewidth = 0.9, alpha = 0.8) +
  geom_vline(xintercept = as.numeric(as.Date("2022-08-08")),
             linetype = "dashed", color = "red") +
  labs(
    title = "Daily Transaction Counts",
    subtitle = "Red dashed line = Tornado Cash sanction (2022-08-08)",
    x = "Date", y = "Total Transactions"
  ) +
  theme_minimal() +
  scale_y_continuous(labels = comma)
