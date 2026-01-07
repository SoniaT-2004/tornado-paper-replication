import requests, csv, io, os
import time

API_KEY = ""                                   # your API key
QUERY_ID = "6222087"                           # your query id
BATCH = 10000                                  # adujst this (rows per page)

sess = requests.Session()
sess.headers.update({"X-Dune-API-Key": API_KEY})

parts = []
offset = 0

def fetch_csv_part(offset):
    url = f"https://api.dune.com/api/v1/query/{QUERY_ID}/results/csv?limit={BATCH}&offset={offset}"
    print(f"Fetching CSV: offset={offset} ...", flush=True)
    r = sess.get(url, timeout=120)
    r.raise_for_status()
    return r.content

while True:
    content = fetch_csv_part(offset)
    if not content or len(content) < 5:
        break
    part_file = f"dune_part_{offset}.csv"
    with open(part_file, "wb") as f:
        f.write(content)
    parts.append(part_file)
    
    lines = content.count(b"\n")
    if lines <= 1:
        break

    text = content.decode("utf-8", errors="ignore")
    row_count = sum(1 for _ in io.StringIO(text)) - 1
    if row_count < BATCH:
        break

    offset += BATCH
    time.sleep(3.0)

print(f"Downloaded {len(parts)} part(s). Merging ...")

# ccombine all csv
out_file = "control_gas_fee.csv"
with open(out_file, "w", newline="", encoding="utf-8") as fout:
    writer = None
    for i, p in enumerate(parts):
        with open(p, "r", encoding="utf-8") as fin:
            reader = csv.reader(fin)
            header = next(reader, None)
            if header is None:
                continue
            if writer is None:
                writer = csv.writer(fout)
                writer.writerow(header)
            for row in reader:
                writer.writerow(row)

print(f"Saved: {out_file}")

for p in parts:
    try:
        os.remove(p)
    except OSError:
        pass
print("Cleaned temporary parts.")
