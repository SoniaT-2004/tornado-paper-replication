import json
import pandas as pd

# Load the JSON file
json_path = "ethereum-mainnet.json"
with open(json_path, "r") as f:
    data = json.load(f)

# Convert JSON to DataFrame
df = pd.DataFrame(list(data.items()), columns=["cex_address", "cex_name"])

# Save as CSV
csv_path = "cex_addresses_raw_2.csv"
df.to_csv(csv_path, index=False)