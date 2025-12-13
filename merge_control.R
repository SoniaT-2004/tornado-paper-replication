library(tidyverse)
library(dplyr)

high_control <- read_csv("/Users/soniatao/Desktop/Tornado/high_control.csv", show_col_types = FALSE)
low_control <- read_csv("/Users/soniatao/Desktop/Tornado/low_control.csv", show_col_types = FALSE)


df_combined <- bind_rows(high_control %>% select(wallet_address),
    low_control %>% select(source_wallet) %>% rename(wallet_address = source_wallet))

df_final <- df_combined %>%
    filter(wallet_address != "0x0000000000000000000000000000000000000000") %>%
    distinct()

write_csv(df_final, "/Users/soniatao/Desktop/Tornado/tornado_control.csv")
