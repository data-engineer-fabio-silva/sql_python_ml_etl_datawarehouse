CREATE OR REPLACE VIEW public.vw_stg_legacy_fact
AS SELECT 
    TO_DATE(TRIM("date"), 'YYYY-MM-DD') AS "date"
    ,CAST(LOWER(TRIM(in_out)) AS VARCHAR(5)) AS in_out
    ,CAST(LOWER(TRIM(category_nm)) AS VARCHAR(50)) AS category_nm
    ,CAST(LOWER(TRIM(sub_category_nm)) AS VARCHAR(50)) AS sub_category_nm
    ,CAST(REPLACE(TRIM(qtd), ',', '.') AS NUMERIC(13,8)) AS qtd
    ,CAST(REPLACE(TRIM(price), ',', '.') AS NUMERIC(15,4)) AS price
    ,CAST(REPLACE(TRIM(total), ',', '.') AS NUMERIC(15,4)) AS total
    ,CAST(LOWER(TRIM(status)) AS VARCHAR(50)) AS status
    ,CAST(description AS VARCHAR(100)) AS description
    ,CAST(path AS VARCHAR(200)) AS path
FROM ingest_legacy_fact
WHERE 
    LOWER("date") NOT IN ('nat', 'nan');