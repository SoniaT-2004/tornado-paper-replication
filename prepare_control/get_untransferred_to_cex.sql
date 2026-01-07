WITH
user_list AS (
    SELECT DISTINCT address
    FROM dune.tao.result_get_mixer_users
),

-- CEX addresses
cex AS (
    SELECT DISTINCT cex_address AS cex_addr
    FROM dune.tao.dataset_cex_addresses
),

-- All user → CEX deposits in the period
hits AS (
    SELECT DISTINCT
        tx."from" AS addr
    FROM ethereum.transactions tx
    JOIN cex c
      ON tx."to" = c.cex_addr
    WHERE
        tx.block_time >= TIMESTAMP '2022-01-01 00:00:00'
        AND tx.block_time <  TIMESTAMP '2023-08-08 00:00:00'
        AND tx.success = TRUE
        AND tx."from" IN (SELECT address FROM user_list)
)

-- Output only users with no later exit to CEX
SELECT
    u.address
FROM user_list u
LEFT JOIN hits h
    ON u.address = h.addr
WHERE h.addr IS NULL
ORDER BY u.address;
