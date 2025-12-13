library(tidyverse)

high_tx_post1 <- read_csv("/Users/soniatao/Desktop/Tornado/high_tx.csv", show_col_types = FALSE)
high_tx_post2 <- read_csv("/Users/soniatao/Desktop/Tornado/high_tx2.csv", show_col_types = FALSE)

high_tx_post1 <- high_tx_post1 %>% select(wallet_address)
high_tx_post2 <- high_tx_post2 %>% select(wallet_address)

df_combined <- bind_rows(
  high_tx_post1,
  high_tx_post2 %>% select(any_of(names(high_tx_post1)))   # keep only columns that exist in df1
)

df_final <- df_combined %>%
    filter(wallet_address != "0x0000000000000000000000000000000000000000") %>%
    distinct()

write_csv(df_final, "/Users/soniatao/Desktop/Tornado/tornado_final_addresses.csv")
