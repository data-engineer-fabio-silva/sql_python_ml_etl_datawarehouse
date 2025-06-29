CREATE OR REPLACE VIEW public.vw_stg_me
AS SELECT 
    to_date(date, 'YYYY-MM-DD') AS data
    ,CAST(REPLACE(atv_natv, '.0', '') as BOOLEAN) AS atv_natv
    ,CAST(category_nm as varchar(50)) AS category_nm
    ,CAST(REPLACE(price, ',', '.') as numeric(15,4)) AS price
    ,CAST(REPLACE(total, ',', '.') as numeric(15,4)) AS total
    ,CAST(description as varchar(100)) AS description
    ,CAST(path as varchar(200)) AS path
FROM ingest_me
WHERE 
    date not in ('NaT', 'nan')
    AND atv_natv = '1.0'
    AND total <> 'nan' ;