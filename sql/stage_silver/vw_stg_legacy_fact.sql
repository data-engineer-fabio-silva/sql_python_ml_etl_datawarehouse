CREATE OR REPLACE VIEW public.vw_stg_legacy_fact
AS SELECT 
    TO_DATE("date", 'YYYY-MM-DD') AS data
    ,CAST(in_out AS VARCHAR(5)) AS in_out
    ,CAST(TRIM(category_nm) AS VARCHAR(50)) AS category_nm
    ,CAST(TRIM(sub_category_nm) AS VARCHAR(50)) AS sub_category_nm
    ,CAST(REPLACE(qtd, ',', '.') AS NUMERIC(13,8)) AS qtd
    ,CAST(REPLACE(price, ',', '.') AS NUMERIC(15,4)) AS price
    ,CAST(REPLACE(total, ',', '.') AS NUMERIC(15,4)) AS total
    ,CAST(status AS VARCHAR(50)) AS status
    ,CAST(description AS VARCHAR(100)) AS description
    ,CAST(path AS VARCHAR(200)) AS path
FROM ingest_legacy_fact
WHERE date NOT IN ('NaT', 'nan');