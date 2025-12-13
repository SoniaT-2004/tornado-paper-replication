library(dplyr)
library(readr)

treated_df <- read_csv("/Users/soniatao/Desktop/Tornado/nov16/tornado_exposed_mxier_tx_cleaned_new.csv") %>%
  mutate(treated = 1) 

control_df <- read_csv("/Users/soniatao/Desktop/Tornado/nov16/tornado_control_mxier_tx_cleaned.csv") %>%
  mutate(treated = 0)

# combine panel
df <- bind_rows(treated_df, control_df) %>%
  mutate(
    bimonth = as.Date(bimonth),                    # 清理时间
    user_wallet = as.character(user_wallet),
    num_interactions = as.integer(num_interactions),
    post = ifelse(bimonth >= as.Date("2022-08-08"), 1, 0),       # 制裁后
    did = treated * post                           # DiD 交互项
  ) %>%
  arrange(user_wallet, bimonth)

write_csv(df, "/Users/soniatao/Desktop/Tornado/full_panel_nov16_new.csv")

