library(dplyr)
library(readr)
library(lubridate)
library(fixest)      # TWFE + clustered se
library(ggplot2)
library(kableExtra)
library(car)
library(broom)

panel <- read_csv("/Users/soniatao/Desktop/Tornado/nov16/panel_with_fee_nov16.csv")

df <- panel %>%
  group_by(user_wallet) %>%
  mutate( did  = treated * post,
          log_interactions = log(num_interactions+1)) %>%
  ungroup()

m1 <- feols(
  num_interactions ~ post + treated + did | user_wallet + bimonth, # individual and time FE
  data = df,
  cluster = ~ user_wallet
)

summary(m1)

m2 <- feols(
  log_interactions ~ post + treated + did  + avg_gas_fee_eth | user_wallet + bimonth, # individual and time FE
  data = df,
  cluster = ~ user_wallet
)

summary(m2)


# create relative time（use one period pre sanction as basis）
df_event <- df %>%
  mutate(
    rel_time = as.numeric(bimonth - as.Date("2022-08-01")) %/% 60,  # 60days
    rel_time = ifelse(rel_time < -12, -12, rel_time),
    rel_time = ifelse(rel_time > 16, 16, rel_time)
  ) %>%
  filter(!is.na(rel_time)) %>%
  filter(rel_time >= -6)


# check parallel trend assumption
model <- feols(
  log_interactions ~ i(rel_time, treated, ref = -1) | user_wallet + bimonth,
  data = df_event,
  cluster = ~ user_wallet
)

iplot(
  model,
  xlab = "Relative period (bimonth)", 
  ylab = "Treated - Control (log interactions)",
  main = "Event-study: effects of TC sanctions"
)
abline(v = 0, lty = 2, col = "red")

# check parallel trend assumption
pre_lags <- paste0("rel_time::", -5:-2, ":treated")
joint_test <- linearHypothesis(
  model,
  hypothesis.matrix = pre_lags,   # vector of names
  vcov. = vcov(model, cluster = "user_wallet")   # same clustering as model
)

print(joint_test)

pre_lags_robust <- paste0("rel_time::", -6:-2, ":treated")
linearHypothesis(model, pre_lags_robust)