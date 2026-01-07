-- Identify exposed wallets inactive
WITH exposed_wallets AS (
  SELECT 
    address AS wallet_address
  FROM dune.tao.result_get_untransferred
)

SELECT 
  w.wallet_address,
  COUNT(*) AS tx_count_post_sanction
FROM exposed_wallets w
LEFT JOIN ethereum.transactions t
  ON t."from" = TRY_CAST(w.wallet_address AS varbinary)  -- Cast for address matching
WHERE t.block_time > CAST('2024-01-01' AS TIMESTAMP)
GROUP BY w.wallet_address
HAVING COUNT(t.hash) < 10  -- Adjust threshold as needed
ORDER BY tx_count_post_sanction ASC