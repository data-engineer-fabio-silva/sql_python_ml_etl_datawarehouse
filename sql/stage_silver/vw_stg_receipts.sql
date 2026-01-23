CREATE OR REPLACE VIEW public.vw_stg_receipts
AS SELECT 
    TO_DATE(TRIM("date"), 'YYYY-MM-DD') AS "date"
    ,CAST(REPLACE(TRIM(receipt_number), ' ', '') AS VARCHAR(45)) AS receipt_nb
    ,CAST(TRIM(count_item) AS INTEGER) AS item_nb
    ,CAST(REPLACE(TRIM(cod_item), '.0', '') AS BIGINT) AS cod_item
    ,CAST(LOWER(TRIM(description)) AS VARCHAR(30)) AS description
    ,CAST(REPLACE(TRIM(qtd_item), ',', '.') AS NUMERIC(15,4)) AS qtd
    ,CAST(REPLACE(TRIM(qtd_unit), ',', '.') AS VARCHAR(5)) AS qtd_unit
    ,CAST(REPLACE(TRIM(value_unit), ',', '.') AS VARCHAR(10)) AS value_unit
    ,CAST(NULLIF(LOWER(TRIM(value_tax)), 'nan') AS NUMERIC(15,4)) AS value_tax
    ,CAST(NULLIF(LOWER(TRIM(value_item)), 'nan') AS NUMERIC(15,4)) AS total_price
    ,CAST(LOWER(TRIM(category)) AS VARCHAR(50)) AS category
    ,CAST(NULLIF(LOWER(TRIM(name_item)), 'nan') AS VARCHAR(100)) AS item_nm
    ,CAST(path AS VARCHAR(200)) AS path
FROM ingest_receipts
WHERE 
    LOWER(cod_item) <> 'nan';