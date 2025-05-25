-- public.vw_kpi_meta source

CREATE OR REPLACE VIEW public.vw_kpi_meta
AS WITH meta_subcat_union AS (
   SELECT 
      TRIM(vslf.sub_category_nm) AS sub_category_nm
      ,vslf.total
   FROM vw_stg_legacy_fact vslf
   WHERE vslf.category_nm = 'meta'
   
   UNION ALL
   
   SELECT 
      TRIM(vsg.category_nm) AS sub_category_nm
      ,vsg.total
   FROM vw_stg_go vsg
)
SELECT 
   sub_category_nm
   ,sum(total) AS total
FROM meta_subcat_union
GROUP BY sub_category_nm
ORDER BY (sum(total)) DESC;