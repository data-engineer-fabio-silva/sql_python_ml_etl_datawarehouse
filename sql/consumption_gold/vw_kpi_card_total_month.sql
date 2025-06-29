CREATE OR REPLACE VIEW public.vw_kpi_card_total_month
AS SELECT 
   category_nm AS card
   ,date_part('month', data) AS month_nb
   ,sum(total) AS total
FROM vw_stg_bank_cards 
GROUP BY card, month_nb
ORDER BY month_nb ASC, total DESC;