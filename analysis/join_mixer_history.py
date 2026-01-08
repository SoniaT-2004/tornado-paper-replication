import pandas as pd
import pathlib
from datetime import datetime
 
folder_path = pathlib.Path("mixers/mixer_history_old")
output_file = "mixer_sum_erc20.csv"

# Read all CSVs and parse dates flexibly
all_dfs = []
for csv_file in folder_path.glob("*.csv"):
    df = pd.read_csv(
        csv_file,
        usecols=['day', 'erc20_tx_count'],
        dtype={'erc20_tx_count': float}
    )
    
    # Try multiple common date formats
    df['day'] = pd.to_datetime(df['day'], errors='coerce').dt.date
    
    # Optional: warn about unparsed dates
    if df['day'].isna().any():
        print(f"Warning: Some dates in {csv_file.name} could not be parsed:")
        print(df[df['day'].isna()]['day'].unique())
    
    all_dfs.append(df.dropna(subset=['day']))  # drop invalid dates

# Combine and sum by day
combined = pd.concat(all_dfs, ignore_index=True)
summary = (
    combined
    .groupby('day', as_index=False)['erc20_tx_count']
    .sum()
    .sort_values('day')
)

# Format day as "2024/8/31" (no leading zeros)
summary['day'] = summary['day'].apply(lambda d: f"{d.year}/{d.month}/{d.day}")


summary.to_csv(output_file, index=False)
print(f"Done! {len(summary)} unique days → {output_file}")