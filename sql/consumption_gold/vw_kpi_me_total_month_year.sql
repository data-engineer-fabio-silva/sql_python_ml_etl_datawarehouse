CREATE OR REPLACE VIEW public.vw_kpi_me_total_month_year
AS SELECT 
   category_nm AS category
   ,DATE_PART('month', "date") AS month_nb
   ,DATE_PART('year', "date") AS year_nb
   ,SUM(total) AS total
FROM public.vw_stg_me
GROUP BY category_nm, month_nb, year_nb
ORDER BY month_nb ASC, total DESC;

-- UNION ALL

-- SELECT
--     sub_category_nm AS category
--     ,DATE_PART('month', "date") AS month_nb
--     ,DATE_PART('year', "date") AS year_nb
--     ,total
-- FROM public.vw_stg_legacy_fact 
-- WHERE LOWER(category_nm) = 'gasto mensal';

