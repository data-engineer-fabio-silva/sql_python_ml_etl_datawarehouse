CREATE OR REPLACE VIEW public.vw_stg_go
AS SELECT 
    TO_DATE(TRIM("date"), 'YYYY-MM-DD') AS "date"
    ,CAST(REPLACE(TRIM(atv_natv), '.0', '') AS BOOLEAN) AS atv_natv
    ,CAST(LOWER(TRIM(in_out)) AS VARCHAR(5)) AS in_out
    ,CAST(LOWER(TRIM(category_nm)) AS VARCHAR(50)) AS category_nm
    ,CAST(REPLACE(TRIM(price), ',', '.') AS NUMERIC(15,4)) AS price
    ,CAST(REPLACE(TRIM(total), ',', '.') AS NUMERIC(15,4)) AS total
    ,CAST(description AS VARCHAR(100)) AS description
    ,CAST(path AS VARCHAR(200)) AS path
FROM ingest_go
WHERE 
    LOWER("date") NOT IN ('nat', 'nan')
        AND atv_natv = '1.0'
        AND LOWER(TRIM(total)) <> 'nan';