library(tidyverse)

df1 <- read_csv("/Users/soniatao/Desktop/Tornado/step1/tornado_low_tx_pre.csv", show_col_types = FALSE)
df2 <- read_csv("/Users/soniatao/Desktop/Tornado/step1/tornado_low_tx_post.csv", show_col_types = FALSE)

df_combined <- bind_rows(
  df1,
  df2 %>% select(any_of(names(df1)))   # keep only columns that exist in df1
)

df_final <- df_combined %>% distinct(wallet_address)

write_csv(df_final, "/Users/soniatao/Desktop/Tornado/tornado_low_tx.csv")
