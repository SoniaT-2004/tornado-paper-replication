library(tidyverse)
library(lubridate)
library(broom)

df <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/mixer_history_old/mixer_sum.csv")

df <- df %>%
  mutate(day = ymd(day)) %>%
  arrange(day)

# Summarize daily total transaction count
df_daily <- df %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))

sanction_date <- as.Date("2022-08-08")

df_daily <- df_daily %>%
  mutate(
    t = as.numeric(day - min(day)) + 1, # running time index
    post = if_else(day >= sanction_date, 1, 0), # post dummy
    t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
  )

# smooth series (7-day moving average)
df_daily <- df_daily %>%
  mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 7, fill = NA, align = "right"))

# use a lag window to allow gradual change
df_daily <- df_daily %>%
  mutate(days_since = as.numeric(day - sanction_date)) %>%
  mutate(post_ramp = pmax(days_since, 0))  # increases linearly after event

# ITS with both immediate (post) and gradual (post_ramp) effects
model <- lm(daily_tx ~ t + post + post_ramp, data = df_daily)
summary(model)

ggplot(df_daily, aes(x = day, y = daily_tx_ma7)) +
  geom_line(color = "gray40") +
  geom_vline(xintercept = as.numeric(sanction_date), linetype = "dashed", color = "black") +
  #geom_line(aes(y = fitted(model)), color = "blue", linewidth = 1) +
  labs(
    #title = "Daily Activity",
    #subtitle = "Red line = Tornado Cash sanction (2022-08-08)",
    x = "", y = ""
  ) +
  theme_minimal()
