-- Get all distinct wallets that DEPOSITED to listed Tornado pool contracts
-- Time window: 2020-01-01 (inclusive) to 2022-08-01 (inclusive)
WITH
pools AS (
  -- replace with your uploaded table name if different
  SELECT DISTINCT address AS pool_addr
  FROM dune.tao.dataset_tornado_listed_pools
  WHERE address IS NOT NULL
),

-- 1) ETH deposits: external txs whose "to" is a pool contract
eth_deposits AS (
  SELECT
    t."from"      AS wallet_address,
    t.block_time  AS deposit_time,
    t.hash        AS tx_hash
  FROM ethereum.transactions t
  JOIN pools p
    ON t."to" = p.pool_addr
  WHERE t.block_time BETWEEN TIMESTAMP '2020-01-01 00:00:00'
                         AND TIMESTAMP '2022-08-01 23:59:59'
    -- exclude zero-value contract calls
    AND COALESCE(t.value, CAST(0 AS decimal)) <> 0
),

-- 2) ERC-20 deposits: token Transfer events whose "to" is a pool contract
erc20_deposits AS (
  SELECT
    e."from"         AS wallet_address,   -- token sender
    e.evt_block_time AS deposit_time,
    e.evt_tx_hash    AS tx_hash
  FROM erc20_ethereum.evt_Transfer e
  JOIN pools p
    ON e."to" = p.pool_addr
  WHERE e.evt_block_time BETWEEN TIMESTAMP '2020-01-01 00:00:00'
                            AND TIMESTAMP '2022-08-01 23:59:59'
),

-- 3) union all deposit sources
all_deposits AS (
  SELECT * FROM eth_deposits
  UNION ALL
  SELECT * FROM erc20_deposits
)

-- 4) return distinct depositors with earliest deposit in window and example tx
SELECT
  wallet_address,
  1 AS treated,
  MIN(deposit_time)                            AS first_deposit_time,
  min_by(tx_hash, deposit_time)                AS example_tx_hash
FROM all_deposits
GROUP BY wallet_address
ORDER BY first_deposit_time;
