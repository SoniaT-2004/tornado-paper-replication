WITH params AS (
    SELECT
        TIMESTAMP '2020-01-01 00:00:00' AS start_ts,
        TIMESTAMP '2025-09-01 00:00:00' AS end_ts
),

users AS (
    SELECT
        CAST(wallet_address AS VARBINARY) AS user_wallet
    FROM dune.tao.dataset_tornado_control_cleaned   -- adjust name when getting gas fee for treated group
),

-- Bimonthly calendar: 2020-01-01, 2020-03-01, ..., 2022-09-01
calendar AS (
    SELECT x AS bimonth
    FROM UNNEST(
        SEQUENCE(
            (SELECT start_ts FROM params),
            (SELECT end_ts   FROM params),
            INTERVAL '2' MONTH
        )
    ) AS t(x)
),

-- All user × bimonth combinations
user_calendar AS (
    SELECT
        u.user_wallet,
        c.bimonth
    FROM users u
    CROSS JOIN calendar c
),

-- Wallet-level avg gas fee per bimonth
tx_gas AS (
    SELECT
        tx."from" AS user_wallet,
        c.bimonth AS bimonth,
        AVG(( CAST(tx.gas_used AS DECIMAL(38, 0)) * CAST(tx.gas_price AS DECIMAL(38, 0)) ) / 1e18) AS avg_gas_fee_eth
    FROM ethereum.transactions tx
    JOIN users u
      ON tx."from" = u.user_wallet
    JOIN calendar c
      ON tx.block_time >= c.bimonth
     AND tx.block_time <  c.bimonth + INTERVAL '2' MONTH
    WHERE tx.block_time >= (SELECT start_ts FROM params)
      AND tx.block_time <  (SELECT end_ts   FROM params)
      AND tx.success = TRUE
    GROUP BY
        tx."from",
        c.bimonth
),

-- Final panel: fill missing periods with 0 gas fee
panel AS (
    SELECT
        uc.user_wallet,
        uc.bimonth,
        COALESCE(g.avg_gas_fee_eth, 0.0) AS avg_gas_fee_eth
    FROM user_calendar uc
    LEFT JOIN tx_gas g
      ON uc.user_wallet = g.user_wallet
     AND uc.bimonth    = g.bimonth
)

SELECT *
FROM panel
ORDER BY user_wallet, bimonth;
