# tornado-paper-replication
This repo provides the code to replicate the dataset and the regression output in the paper Disrupting Illicit Crypto Flows: The Effects of the Tornado Cash Sanctions on User Behavior and Protocol Activity

# What’s used
- Dune sql query, python, R, Etherscan
- API key needed
- Check the two python scripts in dune_csv_download_helper file for scraping datasets from Dune
- Mixer and CEX addresses come from Etherscan
- Tornado listed pools retrieved from OFAC Cyber-related Designation: https://ofac.treasury.gov/recent-actions/20220808

# Work flow
Prepare treated
- get_tornado_depositors.sql
- get_transferred_tornado_address.sql
- get_high_tx.sql
- get_low_tx.R
- get_source_wallets.sql
- get_high_tx.sql
- merge_useful_tx.R
- get_non_robots.sql
- get_mixer_interaction_count.sql
- clean_date.R

Prepare control (same logic and step, but some R replaced with sql)
- get_mixer_users.sql
- get_untransferred_to_cex.sql
- get_high_tx.sql
- get_low_tx.sql
- get_source_wallets.sql
- get_high_control.sql
- get_low_source_control.sql
- merge_control.R
- get_non_robots.sql
- get_mixer_interaction_count.sql
- clean_nonexposed.R

Prepare panels
- merge_all.R: get full panel without gas fee
- get_gas_fee.sql (run this for both treated and untreated)
- merge_fee_tx.R: get full panel with gas fee

Analysis (plots, summary stats, regressions)
- mixer_trend.R (input retrieved using join_mixer_history.py or individual mixer history): used to draw activity trend of any single mixer or the sixe mixers combined
- mixer_trend_altogether.py: plots and compares transaction/activity history of 6 substitute mixers
- tornado_deposit_summary_stats.py: summary stats for Tornado Cash initial deposit trend
- DiD.R: summary stats, regression, event study, and joint wald test for the full panel without gas fee
- DiD_with_gas.R: summary stats, regression, and event study for the full panel with gas fee included
- interaction_summary.R: plot sampled users' total interactions with mixers over time
- two_dfs_plot.R: compare treated and untreated users interaction counts with mixers

# Contact
soniamm.tao@mail.utoronto.ca
