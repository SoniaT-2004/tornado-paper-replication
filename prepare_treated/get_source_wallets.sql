-- Identify source wallets for low-transaction count wallets

WITH low_count_wallets AS (
  SELECT TRY_CAST(wallet_address AS varbinary) AS wallet
  FROM dune.sosotao.dataset_tornado_low_tx
),
cex_list AS (
  SELECT TRY_CAST(cex_address AS varbinary) AS cex_addr
  FROM dune.sosotao.dataset_cex_addresses
),

-- 1. convert all inflows (ETH + any ERC-20) to USD equivalent
inflows AS (
  -- ETH section
  SELECT
    w.wallet AS target_wallet,
    t."from" AS source_wallet,
    t.value / 1e18 * 2500 AS usd_value     -- 2021 average price
  FROM low_count_wallets w
  JOIN ethereum.transactions t
    ON t."to" = w.wallet AND t."from" <> t."to"
   AND t.value >= 1e15
   AND t.block_time < TIMESTAMP '2022-07-31'
   AND t.block_time > TIMESTAMP '2018-01-01'
  
  UNION ALL
  
  -- ERC-20 section (any token, >= $10 equivalent)
  SELECT
    w.wallet AS target_wallet,
    e."from" AS source_wallet,
    e.value / POWER(10, COALESCE(tok.decimals,18)) * COALESCE(p.price, 0) AS usd_value
  FROM low_count_wallets w
  JOIN erc20_ethereum.evt_Transfer e
    ON e."to" = w.wallet AND e."from" <> e."to"
   AND e.evt_block_time < TIMESTAMP '2022-07-31'
   AND e.evt_block_time > TIMESTAMP '2018-01-01'
  LEFT JOIN tokens_ethereum.erc20 tok ON tok.contract_address = e.contract_address
  LEFT JOIN prices.usd p 
    ON p.contract_address = e.contract_address 
   AND DATE_TRUNC('day', p.minute) = DATE_TRUNC('day', e.evt_block_time)
  WHERE e.value / POWER(10, COALESCE(tok.decimals,18)) * COALESCE(p.price, 0) >= 10
),

-- 2. aggregate all inflows
src_summary AS (
  SELECT
    target_wallet,
    source_wallet,
    COUNT(*)                                            AS inflow_tx_cnt,
    SUM(usd_value)                                      AS total_eth_in,
    MAX(usd_value)                                      AS max_eth_in,
    SUM(usd_value) / NULLIF(COUNT(*),0)                 AS avg_eth_per_tx
  FROM inflows
  GROUP BY target_wallet, source_wallet
),

-- 3. source wallet history activity
src_activity AS (
  SELECT
    "from"                                              AS wallet,
    COUNT(*)                                            AS src_total_tx,
    COUNT(DISTINCT DATE(block_time))                    AS src_active_days,
    COUNT(DISTINCT "to")                                AS src_distinct_to
  FROM ethereum.transactions
  WHERE block_time < TIMESTAMP '2022-07-31'
    AND block_time > TIMESTAMP '2018-01-01'
    AND "from" IN (SELECT source_wallet FROM src_summary)
  GROUP BY "from"
),

-- 4. final merge + scoring formula
final AS (
  SELECT
    s.target_wallet,
    s.source_wallet,
    s.inflow_tx_cnt,
    s.total_eth_in,
    s.max_eth_in,
    s.avg_eth_per_tx,
    COALESCE(a.src_total_tx,0)          AS src_total_tx,
    COALESCE(a.src_active_days,0)       AS src_active_days,
    COALESCE(a.src_distinct_to,0)       AS src_distinct_to,
    CASE WHEN c.cex_addr IS NOT NULL THEN 1 ELSE 0 END AS is_cex,
    CASE WHEN con.address IS NOT NULL THEN 1 ELSE 0 END AS is_contract,
    LEAST(100,
      LEAST(25, s.inflow_tx_cnt * 3) +
      LEAST(25, LN(1 + s.total_eth_in) * 5) +
      LEAST(25, COALESCE(a.src_total_tx,0) / 20) +
      LEAST(25, COALESCE(a.src_active_days,0)/10 + LEAST(5, COALESCE(a.src_distinct_to,0)/50))
    ) AS personal_score
  FROM src_summary s
  LEFT JOIN src_activity a      ON a.wallet = s.source_wallet
  LEFT JOIN cex_list c          ON c.cex_addr = s.source_wallet
  LEFT JOIN ethereum.contracts con ON con.address = s.source_wallet
),

-- 5. final filter + top-2
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY target_wallet ORDER BY personal_score DESC) AS rn
  FROM final
  WHERE is_cex = 0
    AND is_contract = 0
    AND src_total_tx >= 30
    AND src_active_days >= 7
    AND personal_score > 70
)

-- final output
SELECT
  target_wallet,
  source_wallet,
  inflow_tx_cnt,
  total_eth_in,
  max_eth_in,
  avg_eth_per_tx,
  src_total_tx,
  src_active_days,
  src_distinct_to,
  personal_score
FROM ranked
WHERE rn <= 1
ORDER BY target_wallet, personal_score DESC;