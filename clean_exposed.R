library(tidyverse)
library(data.table)

main <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_exposed_addresses.csv")
low_tx <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_low_tx.csv")
source_wallets <- read_csv("/Users/soniatao/Desktop/Tornado/source_wallets.csv")
transferred <- read_csv("/Users/soniatao/Desktop/Tornado/transferred.csv")

main <- main %>% select(wallet_address)
source_wallets <- source_wallets %>% select(source_wallet)
transferred <- transferred %>% select(address)

df_combined <- bind_rows(main, source_wallets %>%
    select(any_of(names(main))) # keep only columns that exist in df1
    )

addresses_to_remove <- low_tx %>% pull(wallet_address)
df_final <- df_combined %>% filter(!wallet_address %in% addresses_to_remove)

df_cleaned <- df_final %>% distinct()
df_cleaned <- df_cleaned %>% filter(wallet_address != "0x0000000000000000000000000000000000000000")

addresses_to_remove2 <- transferred %>% pull(address)
df <- df_cleaned %>% filter(!wallet_address %in% addresses_to_remove2)

write_csv(df, "/Users/soniatao/Desktop/Tornado/clean_exposed_addresses.csv")
