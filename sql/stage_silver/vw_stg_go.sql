CREATE OR REPLACE VIEW public.vw_stg_go
AS SELECT 
    TO_DATE("date", 'YYYY-MM-DD') AS data
    ,CAST(REPLACE(atv_natv, '.0', '') AS BIT(1)) AS atv_natv
    ,CAST(in_out AS VARCHAR(5)) AS in_out
    ,CAST(category_nm AS VARCHAR(50)) AS category_nm
    ,CAST(REPLACE(price, ',', '.') AS NUMERIC(15,4)) AS price
    ,CAST(REPLACE(total, ',', '.') AS NUMERIC(15,4)) AS total
    ,CAST(description AS VARCHAR(100)) AS description
    ,CAST(path AS VARCHAR(200)) AS path
FROM ingest_go
WHERE date NOT IN ('NaT', 'nan');