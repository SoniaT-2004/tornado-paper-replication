import requests, csv, io, os
import time

API_KEY = "eD33FIunRML2oOozBVbMlnTu9nDSIVSo"       # 例如 sk_abc123...
QUERY_ID = "6222087"                           # 你的查询编号
BATCH = 10000                                  # 每页 1000 行

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

# 1) 分页下载 CSV 分片
while True:
    content = fetch_csv_part(offset)
    # 空/很小：可能没有数据
    if not content or len(content) < 5:
        break
    part_file = f"dune_part_{offset}.csv"
    with open(part_file, "wb") as f:
        f.write(content)
    parts.append(part_file)

    # 判断是否最后一页：当前页行数 < BATCH 即可停止
    # 读取当前分片行数（含表头）
    lines = content.count(b"\n")
    # 有时最后一行不以 \n 结尾，简单稳妥再读文本数
    if lines <= 1:  # 只有表头或空
        break

    # 估算：行数(含表头) - 1 < BATCH → 最后一页
    # 用 io.StringIO 统计更准确
    text = content.decode("utf-8", errors="ignore")
    row_count = sum(1 for _ in io.StringIO(text)) - 1
    if row_count < BATCH:
        break

    offset += BATCH
    time.sleep(3.0)

print(f"Downloaded {len(parts)} part(s). Merging ...")

# 2) 合并所有分片为一个 CSV（只保留第一个分片的表头）
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
                writer.writerow(header)  # 只写一次表头
            for row in reader:
                writer.writerow(row)

print(f"Saved: {out_file}")

# 3) 清理分片
for p in parts:
    try:
        os.remove(p)
    except OSError:
        pass
print("Cleaned temporary parts.")
