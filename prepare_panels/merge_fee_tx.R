library(dplyr)
library(readr)

# Read the two CSV files
main <- read_csv("/Users/soniatao/Desktop/Tornado/full_panel.csv")   # columns: date, id, interactions
control_gas <- read_csv("/Users/soniatao/Desktop/Tornado/control_gas_fee.csv")   # columns: date, id, fees
treated_gas <- read_csv("/Users/soniatao/Desktop/Tornado/treated_gas_fee.csv")   # columns: date, id, fees

gas <- bind_rows(control_gas, treated_gas) %>%
  mutate(
    bimonth = as.Date(bimonth),
    user_wallet = as.character(user_wallet),
    avg_gas_fee_eth
  ) %>%
  arrange(user_wallet, bimonth)

main <- main %>% mutate(bimonth = as.Date(bimonth))

df <- main %>% left_join(gas, by = c("bimonth", "user_wallet"))

write_csv(df, "/Users/soniatao/Desktop/Tornado/panel_with_fee.csv")
