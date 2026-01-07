-- 1. List of your uploaded Tornado-exposed addresses
WITH my_addresses AS (
    SELECT source_wallet AS addr
    FROM dune.tao.result_get_source
),

-- 2. First on-chain transaction (any tx)
first_tx AS (
    SELECT  "from"               AS addr,
            MIN(block_time)      AS first_time
    FROM    ethereum.transactions
    WHERE   "from" IN (SELECT addr FROM my_addresses)
    GROUP BY 1
),

-- 3. Total transaction count
tx_cnt AS (
    SELECT  "from"      AS addr,
            COUNT(*)    AS total_txs
    FROM    ethereum.transactions
    WHERE   "from" IN (SELECT addr FROM my_addresses)
    GROUP BY 1
),

-- 4. DEX trading activity (distinct DEX protocols, via tx_from/tx_to)
dex_activity AS (
    SELECT  addr,
            COUNT(DISTINCT project) AS distinct_dex_projects
    FROM (
        SELECT  tx_from AS addr, project
        FROM    dex.trades
        WHERE   blockchain = 'ethereum'
          AND   tx_from IN (SELECT addr FROM my_addresses)
        UNION ALL
        SELECT  tx_to AS addr, project
        FROM    dex.trades
        WHERE   blockchain = 'ethereum'
          AND   tx_to IN (SELECT addr FROM my_addresses)
    ) dex_user_trades
    GROUP BY 1
),

-- 5. Distinct ERC-20 tokens ever meaningfully held (exclude dust)
erc20_holds AS (
    SELECT  "to"                     AS addr,
            COUNT(DISTINCT contract_address) AS distinct_tokens
    FROM    erc20_ethereum.evt_transfer
    WHERE   "to" IN (SELECT addr FROM my_addresses)
      AND   value >= POWER(10, 14)  -- ~0.0001 ETH equiv (10^14 wei); adjust if needed
    GROUP BY 1
),

-- 6. Combine everything
candidates AS (
    SELECT  a.addr,
            f.first_time,
            c.total_txs,
            COALESCE(d.distinct_dex_projects, 0) AS dex_projects,
            COALESCE(e.distinct_tokens, 0)       AS token_variety
    FROM    my_addresses a
    JOIN    first_tx      f ON a.addr = f.addr
    JOIN    tx_cnt        c ON a.addr = c.addr
    LEFT JOIN dex_activity d ON a.addr = d.addr
    LEFT JOIN erc20_holds  e ON a.addr = e.addr
)

-- 7. Final filters + DeFi-experience proxy
SELECT DISTINCT
        addr                               AS wallet_address,
        first_time,
        total_txs,
        dex_projects,
        token_variety
FROM    candidates
WHERE   first_time < DATE('2019-01-01')
  AND   total_txs  > 50
  AND   total_txs  < 10000
  AND   (dex_projects >= 2 OR token_variety >= 3)
  AND   dex_projects  < 20
  AND   token_variety < 100
ORDER BY total_txs DESC, first_time ASC;