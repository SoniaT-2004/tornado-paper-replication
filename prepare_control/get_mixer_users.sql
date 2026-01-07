WITH params AS (
  SELECT
    TIMESTAMP '2020-01-01 00:00:00+00' AS start_ts,
    TIMESTAMP '2022-08-07 00:00:00+00' AS end_ts
),

pools AS (
  SELECT DISTINCT 
    CAST(contract_address AS VARBINARY) AS pool_address
  FROM dune.tao.dataset_mixer_addresses
),

-- EOA -> pool (deposits)
depositors AS (
  SELECT
    tx."from"      AS address,
    tx.block_time  AS ts
  FROM ethereum.transactions tx
  JOIN pools p
    ON tx."to" = p.pool_address
  WHERE tx.block_time >= (SELECT start_ts FROM params)
    AND tx.block_time <  (SELECT end_ts FROM params)
    AND tx.success = TRUE  -- Only keep those successful transactions
),

agg AS (
  SELECT
    address,
    COUNT(*) AS deposit_tx_cnt
  FROM depositors
  GROUP BY address
)

SELECT
  agg.address,                                   -- Varbinary
  CAST(agg.address AS VARCHAR) AS address_hex,
  1 AS exposed,
  deposit_tx_cnt
FROM agg
ORDER BY deposit_tx_cnt DESC;