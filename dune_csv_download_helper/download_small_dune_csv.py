import requests
import os

# === 1. CONFIGURATION ===
API_KEY = "eD33FIunRML2oOozBVbMlnTu9nDSIVSo"   # API key
QUERY_ID = 6222257              # Dune query ID
OUTPUT_FILE = f"untransferred.csv"
LIMIT = 5000                    # Adjust if your result set > 1000 rows
OFFSET = 0

# === 2. MAKE REQUEST ===
url = f"https://api.dune.com/api/v1/query/{QUERY_ID}/results/csv?limit={LIMIT}&offset={OFFSET}"
headers = {"X-Dune-API-Key": API_KEY}

print("Fetching CSV data from Dune ...")
response = requests.get(url, headers=headers)

# === 3. CHECK & SAVE ===
if response.status_code == 200:
    with open(OUTPUT_FILE, "wb") as f:
        f.write(response.content)
    print(f"CSV saved to: {OUTPUT_FILE}")
else:
    print(f"Error {response.status_code}: {response.text}")
