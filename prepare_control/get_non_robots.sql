-- Get rid of extreme values
WITH exposed_wallets AS (
  SELECT wallet_address
  FROM dune.tao.dataset_tornado_control_addresses  -- Replace with your actual table path
)

SELECT 
  w.wallet_address,
  COUNT(*) AS tx_count_post_sanction
FROM exposed_wallets w
LEFT JOIN ethereum.transactions t
  ON t."from" = TRY_CAST(w.wallet_address AS varbinary)  -- Cast for address matching in Dune
WHERE t.block_time > CAST('2020-01-01' AS TIMESTAMP)
GROUP BY w.wallet_address
HAVING COUNT(t.hash) < 10000  -- Adjust threshold as needed
ORDER BY tx_count_post_sanction ASC
