# tornado-paper-replication
This repo provides the code to replicate the dataset and the regression output in the paper Disrupting Illicit Crypto Flows: The Effects of the Tornado Cash Sanctions on User Behavior and Protocol Activity

# What’s used
- Dune sql query, python, R, Etherscan

# Work flow
Prepare treated
- Get_tornado_depositors.sql
- Get_transferred_tornado_address.sql
- Get_high_tx.sql
- Get_low_tx.R
- Get_source_wallets.sql
- Get_high_tx.sql
- merge_useful_tx.R
- Get_non_robots.sql
- Get_mixer_interaction_count.sql
- Clean_date.R

Prepare control (same logic and step, but some R replaced with sql)
- Get_mixer_users.sql
- Get_untransferred_to_cex.sql
- Get_high_tx.sql
- Get_low_tx.sql
- Get_source_wallets.sql
- Get_high_control.sql
- Get_low_source_control.sql
- merge_control.R
- Get_non_robots.sql
- Get_mixer_interaction_count.sql
- Clean_nonexposed.R

Prepare panels
- merge_all.R --> get full panel without gas fee
- get_gas_fee.sql (run this for both treated and untreated)
- merge_fee_tx.R --> get full panel with gas fee

Analysis (plots, summary stats, regressions)
