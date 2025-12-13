import pandas as pd

df1 = pd.read_csv("cex_addresses_raw_1.csv", dtype=str)
df2 = pd.read_csv("cex_addresses_raw_2.csv", dtype=str)

df1 = df1.rename(columns={"address": "cex_address"})

combined_df = pd.concat([df1, df2], ignore_index=True)

combined_df = combined_df.loc[
    ~combined_df["cex_address"].str.lower().duplicated()
]

combined_df.to_csv("cex_addresses.csv", index=False)
