library(tidyverse)
library(data.table)

non_exposed <- read_csv("/Users/soniatao/Desktop/Tornado/nov16/tornado_control_mxier_tx.csv")
exposed <- read_csv("/Users/soniatao/Desktop/Tornado/treated/tornado_final_addresses_cleaned.csv")

exposed <- exposed %>% select(wallet_address) %>% distinct(wallet_address)

non_exposed_date_cleaned <- non_exposed %>%
  mutate(
    bimonth = as.Date(bimonth),           # remove the time part
    user_wallet = as.character(user_wallet),
    num_interactions = as.integer(num_interactions),
    post = ifelse(bimonth >= as.Date("2022-08-08"), 1, 0)
  ) %>%
  arrange(bimonth, user_wallet)

non_exposed_new <- non_exposed_date_cleaned %>%
  group_by(user_wallet) %>%
  filter(
    sum(num_interactions[post == 0]) > 0,
    sum(num_interactions[post == 1]) > 0
  ) %>%
  ungroup()

non_exposed_new <- non_exposed_new %>% select(-post)

addresses_to_remove <- exposed %>% pull(wallet_address)
df_final <- non_exposed_new %>% filter(!user_wallet %in% addresses_to_remove)

df_cleaned <- df_final %>% distinct() %>% filter(user_wallet != "0x0000000000000000000000000000000000000000")

write_csv(df_cleaned, "/Users/soniatao/Desktop/Tornado/nov16/tornado_control_mxier_tx_cleaned.csv")
