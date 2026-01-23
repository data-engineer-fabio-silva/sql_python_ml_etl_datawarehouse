CREATE OR REPLACE VIEW public.vw_kpi_card_total_month_year
AS SELECT 
   category_nm AS card
   ,date_part('month', "date") AS month_nb
   ,date_part('year', "date") AS year_nb
   ,sum(total) AS total
FROM vw_stg_bank_cards 
GROUP BY date_part('month', "date"), date_part('year', "date"), category_nm

UNION ALL

SELECT 
   category_nm AS card
   ,date_part('month', "date") AS month_nb
   ,date_part('year', "date") AS year_nb
   ,sum(total) AS total
FROM vw_stg_legacy_fact
WHERE LOWER(category_nm) LIKE '%cartão%' 
   AND total > 0
GROUP BY date_part('month', "date"), date_part('year', "date"), category_nm 