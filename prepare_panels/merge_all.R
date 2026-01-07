library(tidyverse)
library(dplyr)
library(readr)

treated <- read_csv("/Users/soniatao/Desktop/Tornado/treated/tornado_exposed_mxier_tx_cleaned.csv")

treated_df <- treated %>%
  mutate(
    num_interactions = as.integer(num_interactions),
    post = ifelse(bimonth >= as.Date("2022-08-08"), 1, 0)
  ) %>%
  group_by(user_wallet) %>%
  filter(
    sum(num_interactions[post == 1]) > 0
  ) %>%
  ungroup()

treated_df_final <- treated_df %>%
  select(-post) %>%
  mutate(treated = 1) 

control_df <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_control_mxier_tx_cleaned.csv") %>%
  mutate(treated = 0)

# combine panel
df <- bind_rows(treated_df_final, control_df) %>%
  mutate(
    bimonth = as.Date(bimonth),
    user_wallet = as.character(user_wallet),
    num_interactions = as.integer(num_interactions),
    post = ifelse(bimonth >= as.Date("2022-08-08"), 1, 0),
    did = treated * post
  ) %>%
  arrange(user_wallet, bimonth)

write_csv(df, "/Users/soniatao/Desktop/Tornado/full_panel.csv")

