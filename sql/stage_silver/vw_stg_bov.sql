/*
================================================================================
View Name: public.vw_stg_bov
Author: [Your Name or Team Name]
Created: [YYYY-MM-DD]
Last Modified: [YYYY-MM-DD] by [Modifier's Name]
================================================================================

📌 Description:
This view standardizes and cleans raw data from the staging table `stg_bov`.
It includes type casting, date parsing, and the conversion of textual dashes
("-") into SQL NULLs for numeric fields. The view is intended to serve as a 
cleaned intermediate layer for downstream consumption.

🔗 Dependencies:
- Source table: `public.stg_bov`
- Downstream consumers may include:
  - vw_kpi_total_qtd_valor
  - vw_kpi_setor
  - vw_kpi_categoria

🗃️ Tables Used:
- public.stg_bov

================================================================================
*/

CREATE OR REPLACE VIEW public.vw_stg_bov AS
SELECT 
  CAST(entrada_saida AS VARCHAR(20)) AS entrada_saida
  ,TO_DATE("data", 'DD/MM/YYYY') AS data
  ,CAST(movimentacao AS VARCHAR(100)) AS movimentacao
  ,CAST(produto AS VARCHAR(200)) AS produto_dsc
  ,SPLIT_PART(CAST(produto AS VARCHAR(200)), ' - ', 1) AS produto
  ,CAST(instituicao AS VARCHAR(100)) AS instituicao
  ,CAST(quantidade AS NUMERIC(15,2)) AS quantidade
  ,CAST(NULLIF(preco_unitario, '-') AS NUMERIC(15,2)) AS preco_unitario
  ,CAST(NULLIF(valor_da_operacao, '-') AS NUMERIC(15,2)) AS valor_da_operacao
  ,CAST(path AS VARCHAR(500)) AS path
FROM ingest_bov;