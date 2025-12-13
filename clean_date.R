library(tidyverse)
library(dplyr)

df <- read_csv("/Users/soniatao/Desktop/Tornado/tornado_exposed_mxier_tx.csv")

df_cleaned <- df %>%
  mutate(
    bimonth = as.Date(bimonth),           # 自动去掉时间部分
    user_wallet = as.character(user_wallet),
    num_interactions = as.integer(num_interactions)
  ) %>%
  arrange(bimonth, user_wallet)

write_csv(df_cleaned, "/Users/soniatao/Desktop/Tornado/tornado_exposed_mxier_tx_cleaned.csv")
