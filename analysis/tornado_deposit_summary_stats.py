import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("./step1/tornado_exposed_addresses_full.csv")

df['first_deposit_time'] = pd.to_datetime(df['first_deposit_time'], errors='coerce')

# drop missing or invalid dates
df = df.dropna(subset=['first_deposit_time'])

# group by month
df['month'] = df['first_deposit_time'].dt.to_period('M')
monthly_counts = df.groupby('month').size()

plt.figure(figsize=(10, 5))
monthly_counts.plot(kind='bar', color='skyblue')
plt.title("First Deposit Count per Month")
plt.xlabel("Month")
plt.ylabel("Number of Addresses")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
