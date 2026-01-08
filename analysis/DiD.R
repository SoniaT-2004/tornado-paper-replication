library(dplyr)
library(readr)
library(lubridate)
library(fixest)      # TWFE + clustered se
library(ggplot2)
library(kableExtra)
library(car)
library(broom)

panel <- read_csv("/Users/soniatao/Desktop/Tornado/nov16/merged_panel_with_fee.csv")

df <- panel %>%
  group_by(user_wallet) %>%
  filter(
    sum(num_interactions[post == 0]) > 0,
    sum(num_interactions[post == 1]) > 0
  ) %>%
  mutate( did  = treated * post,
          log_interactions = log(num_interactions+1)) %>%
  ungroup()

m1 <- feols(
  log_interactions ~ post + treated + did | user_wallet + bimonth, # individual and time FE
  data = df,
  cluster = ~ user_wallet
)

summary(m1)

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
  main = "Event-study: effects of TC sanctions",
  ref.line = FALSE
)
abline(v = 0, lty = 2, col = "black")


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










library(ggfixest)

edata <- iplot_data(model)
head(edata)
edata$signif <- ifelse(edata$ci_low > 0 | edata$ci_high < 0, "Significant", "Not significant")
edata$post   <- ifelse(edata$x >= 0, "Post", "Pre")
library(ggplot2)

ggplot(edata, aes(x = x, y = estimate)) +
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, linetype = 2, color = "black") +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.15) +
  geom_point(aes(color = signif), size = 2) +
  scale_color_manual(values = c(
    "Significant" = "red",
    "Not significant" = "black"
  )) +
  labs(
    x = "Relative period (bimonth)",
    y = "Treated - Control (log interactions)",
  ) +
  theme_bw() +
  theme(legend.position = "none") +
  theme(
    axis.title.y = element_text(margin = margin(r = 12)),
    axis.title.x = element_text(margin = margin(t = 12))   # increase top margin of x-label
  )