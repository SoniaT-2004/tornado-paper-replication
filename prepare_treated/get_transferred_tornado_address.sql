-- DISTINCT users with their first CEX hit after the sanction window
WITH
tornado_users AS (
  SELECT DISTINCT wallet_address AS address
  FROM dune.tao.dataset_tornado_exposed_addresses
),
cex AS (
  SELECT DISTINCT cex_address AS cex_addr, cex_name
  FROM dune.tao.dataset_cex_addresses
),
hits AS (
  SELECT
    t."from"       AS tornado_user,
    t."to"         AS cex_addr,
    c.cex_name,
    t.block_time   AS first_hit_time,
    t.hash         AS example_tx,
    ROW_NUMBER() OVER (
      PARTITION BY t."from"
      ORDER BY t.block_time
    ) AS rn
  FROM ethereum.transactions t
  JOIN tornado_users u ON t."from" = u.address
  JOIN cex           c ON t."to"   = c.cex_addr
  WHERE t.block_time BETWEEN TIMESTAMP '2022-08-08 15:00:00'
                         AND TIMESTAMP '2023-08-08 23:59:59'
)
SELECT
  h.tornado_user AS address,
  1              AS transfer,
  h.cex_name,
  h.example_tx,
  h.first_hit_time
FROM hits h
WHERE h.rn = 1                         -- keep only the first CEX hit per user
ORDER BY h.first_hit_time;
