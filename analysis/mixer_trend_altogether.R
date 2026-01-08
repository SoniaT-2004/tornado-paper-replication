library(tidyverse)
library(lubridate)
library(broom)

df1 <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/0xTIP_history.csv")
df2 <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/cyclone_history.csv")
df3 <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/aztec_history.csv")
df4 <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/messier_history.csv")
df5 <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/railgun_history.csv")
df6 <- read_csv("/Users/soniatao/Desktop/Tornado/mixers/zksync_history.csv")

df1 <- df1 %>% mutate(day = ymd(day)) %>% arrange(day)
df1_daily <- df1 %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))
df2 <- df2 %>% mutate(day = ymd(day)) %>% arrange(day)
df2_daily <- df2 %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))
df3 <- df3 %>% mutate(day = ymd(day)) %>% arrange(day)
df3_daily <- df3 %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))
df4 <- df4 %>% mutate(day = ymd(day)) %>% arrange(day)
df4_daily <- df4 %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))
df5 <- df5 %>% mutate(day = ymd(day)) %>% arrange(day)
df5_daily <- df5 %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))
df6 <- df6 %>% mutate(day = ymd(day)) %>% arrange(day)
df6_daily <- df6 %>%
  mutate(total_tx = eth_tx_count + erc20_tx_count) %>%
  group_by(day) %>%
  mutate(day = as.Date(day, format = "%Y/%m/%d")) %>%
  filter(between(day, as.Date("2020-01-01"), as.Date("2025-06-01"))) %>%
  summarise(daily_tx = sum(total_tx, na.rm = TRUE))

sanction_date <- as.Date("2022-08-08")

# 30 days movinng avg
df1_daily <- df1_daily %>% mutate(
    t = as.numeric(day - min(day)) + 1,            # running time index
    post = if_else(day >= sanction_date, 1, 0),    # post dummy
    t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
  ) %>% mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 30, fill = NA, align = "right"))
df2_daily <- df2_daily %>% mutate(
  t = as.numeric(day - min(day)) + 1,            # running time index
  post = if_else(day >= sanction_date, 1, 0),    # post dummy
  t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
) %>% mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 30, fill = NA, align = "right"))
df3_daily <- df3_daily %>% mutate(
  t = as.numeric(day - min(day)) + 1,            # running time index
  post = if_else(day >= sanction_date, 1, 0),    # post dummy
  t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
) %>% mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 30, fill = NA, align = "right"))
df4_daily <- df4_daily %>% mutate(
  t = as.numeric(day - min(day)) + 1,            # running time index
  post = if_else(day >= sanction_date, 1, 0),    # post dummy
  t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
) %>% mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 30, fill = NA, align = "right"))
df5_daily <- df5_daily %>% mutate(
  t = as.numeric(day - min(day)) + 1,            # running time index
  post = if_else(day >= sanction_date, 1, 0),    # post dummy
  t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
) %>% mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 30, fill = NA, align = "right"))
df6_daily <- df6_daily %>% mutate(
  t = as.numeric(day - min(day)) + 1,            # running time index
  post = if_else(day >= sanction_date, 1, 0),    # post dummy
  t_after = if_else(post == 1, t - which(day == sanction_date)[1], 0)
) %>% mutate(daily_tx_ma7 = zoo::rollmean(daily_tx, 30, fill = NA, align = "right"))

df_all_long <- bind_rows(
  df1_daily    %>% mutate(group = "0xMonero"),
  df2_daily    %>% mutate(group = "Cyclone Protocol"),
  df3_daily    %>% mutate(group = "Aztec"),
  df4_daily    %>% mutate(group = "Messier 87 Black Hole"),
  df5_daily    %>% mutate(group = "Railgun"),
  df6_daily    %>% mutate(group = "zkSync")
)

ggplot(df_all_long, aes(x = day, y = daily_tx_ma7)) +
  geom_line(color = "grey40") +
  geom_vline(
    xintercept = as.numeric(as.Date("2022-08-08")),
    linetype = "dashed", color = "red"
  ) +s
  facet_wrap(~ group, ncol = 3, scales = "fixed") +
  labs(
    x = "Date",
    y = "Daily Transactions"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    strip.text = element_text(size = 13, face = "bold")
  )
