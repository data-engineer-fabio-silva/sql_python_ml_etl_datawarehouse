CREATE OR REPLACE VIEW public.vw_stg_bank_cards
AS SELECT 
    to_date(date, 'YYYY-MM-DD') AS data
    ,cast(in_out as varchar(5)) AS in_out
    ,cast(TRIM(category_nm) as varchar(50)) AS category_nm
    ,cast(TRIM(sub_category_nm) as varchar(50)) AS sub_category_nm
    ,cast(replace(qtd, ',', '.') as numeric(13,8)) AS qtd
    ,cast(replace(price, ',', '.') as numeric(15,4)) AS price
    ,cast(replace(total, ',', '.') as numeric(15,4)) AS total
    ,cast(status as varchar(50)) AS status
    ,cast(description as varchar(100)) AS description
    ,cast(path as varchar(200)) AS path
FROM ingest_bank_cards
WHERE date not in ('NaT', 'nan') and total <> 'nan';