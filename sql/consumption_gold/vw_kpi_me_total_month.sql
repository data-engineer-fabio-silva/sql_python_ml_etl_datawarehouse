CREATE OR REPLACE VIEW public.vw_kpi_me_total_month
AS SELECT 
   category_nm AS category
   ,DATE_PART('month', data) AS month_nb
   ,SUM(total) AS total
FROM vw_stg_me
GROUP BY category_nm, month_nb
ORDER BY month_nb ASC, total DESC;