library(tidyverse)

main <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_exposed_addresses.csv")
high_tx_post <- read_csv("/Users/soniatao/Desktop/Tornado/high_tx.csv", show_col_types = FALSE)
transferred <- read_csv("/Users/soniatao/Desktop/Tornado/transferred_address.csv", show_col_types = FALSE)

main <- main %>% select(wallet_address)
high_tx_post <- high_tx_post %>% select(wallet_address)
transferred <- transferred %>% select(address)

addresses_to_remove1 <- transferred %>% pull(address)
main_removed1 <- main %>% filter(!wallet_address %in% addresses_to_remove1)
addresses_to_remove2 <- high_tx_post %>% pull(wallet_address)
main_removed2 <- main_removed1 %>% filter(!wallet_address %in% addresses_to_remove2)

df_cleaned <- main_removed2 %>% distinct()
df_final <- df_cleaned %>% filter(wallet_address != "0x0000000000000000000000000000000000000000")

write_csv(df_final, "/Users/soniatao/Desktop/Tornado/tornado_low_tx.csv")
