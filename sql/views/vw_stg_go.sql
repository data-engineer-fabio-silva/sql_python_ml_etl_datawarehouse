CREATE OR REPLACE VIEW public.vw_stg_go
AS SELECT 
    to_date(date, 'YYYY-MM-DD') AS data
    ,cast(replace(atv_natv, '.0', '') as bit(1)) AS atv_natv
    ,cast(in_out as varchar(5)) AS in_out
    ,cast(category_nm as varchar(50)) AS category_nm
    ,cast(replace(price, ',', '.') as numeric(15,4)) AS price
    ,cast(replace(total, ',', '.') as numeric(15,4)) AS total
    ,cast(description as varchar(100)) AS description
    ,cast(path as varchar(200)) AS path
FROM stg_go
WHERE date not in ('NaT', 'nan');