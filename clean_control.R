library(tidyverse)
library(data.table)

non_exposed <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_control.csv")
exposed <- read_csv("/Users/soniatao/Desktop/Tornado/treated/tornado_final_addresses_cleaned.csv")

exposed <- exposed %>% select(wallet_address) %>% distinct(wallet_address)
non_exposed <- non_exposed %>% select(wallet_address) %>% distinct(wallet_address)

addresses_to_remove <- exposed %>% pull(wallet_address)
df_final <- non_exposed %>% filter(!wallet_address %in% addresses_to_remove)

df_cleaned <- df_final %>% distinct() %>% filter(wallet_address != "0x0000000000000000000000000000000000000000")

write_csv(df_cleaned, "/Users/soniatao/Desktop/Tornado/tornado_control_cleaned.csv")
