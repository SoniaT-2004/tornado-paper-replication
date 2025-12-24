-- ------------------------------------------------------------
-- Inputs to provide (single-column tables):
--   dune.<your_schema>.dataset_privacy_tools_addresses (contract_address)
--   dune.<your_schema>.dataset_user_addresses          (wallet_address)
-- ------------------------------------------------------------

WITH tools AS (
  SELECT contract_address
  FROM dune.sosotao.dataset_mixer_addresses
),

users AS (
  SELECT wallet_address
  FROM dune.sosotao.dataset_tornado_final_addresses_cleaned
),

-- Bimonthly calendar: 2020-01-01, 2020-03-01, ..., 2025-09-01
calendar AS (
  SELECT x AS bimonth
  FROM UNNEST(
    SEQUENCE(
      TIMESTAMP '2020-01-01',
      TIMESTAMP '2025-09-01',
      INTERVAL '2' MONTH
    )
  ) AS t(x)
),

-- User → tool interactions, binned to bimonth starts
tx_counts AS (
  SELECT
    CASE
      WHEN (month(tx.block_time) % 2) = 0
        THEN date_trunc('month', tx.block_time) - INTERVAL '1' MONTH
      ELSE date_trunc('month', tx.block_time)
    END                                              AS bimonth,
    tx."from"                                        AS user_wallet,
    COUNT(*)                                         AS num_interactions
  FROM ethereum.transactions tx
  INNER JOIN users u
    ON tx."from" = u.wallet_address              -- user → tool
  INNER JOIN tools t
    ON tx."to" = t.contract_address              -- restrict to tools
  WHERE tx.success = TRUE
    AND tx.block_time >= TIMESTAMP '2020-01-01'
    -- include the Sep–Oct 2025 bin (later clamped by calendar)
    AND tx.block_time <  TIMESTAMP '2025-11-01'
  GROUP BY 1, 2
),

-- Dense panel: every user × every bimonth
panel AS (
  SELECT c.bimonth, u.wallet_address AS user_wallet
  FROM calendar c
  CROSS JOIN users u
)

SELECT
  p.bimonth,
  p.user_wallet,
  COALESCE(t.num_interactions, 0) AS num_interactions
FROM panel p
LEFT JOIN tx_counts t
  ON t.bimonth = p.bimonth AND t.user_wallet = p.user_wallet
ORDER BY p.bimonth, p.user_wallet;
