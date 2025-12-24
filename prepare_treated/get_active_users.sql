-- Identify exposed wallets still active
WITH exposed_wallets AS (
  SELECT 
    address AS wallet_address
  FROM dune.seaweedtao.result_get_depositors  -- Replace with your actual table path
)

SELECT 
  w.wallet_address,
  COUNT(*) AS tx_count_post_sanction
FROM exposed_wallets w
LEFT JOIN ethereum.transactions t
  ON t."from" = TRY_CAST(w.wallet_address AS varbinary)  -- Cast for address matching in Dune
WHERE t.block_time > CAST('2023-01-01' AS TIMESTAMP)
GROUP BY w.wallet_address
HAVING COUNT(t.hash) > 10  -- Adjust threshold as needed
ORDER BY tx_count_post_sanction ASC