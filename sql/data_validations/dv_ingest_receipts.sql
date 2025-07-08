-- Expectation: No results
SELECT receipt_number
FROM ingest_receipts
WHERE receipt_number != TRIM(receipt_number)