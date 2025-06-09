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
  cast(entrada_saida as varchar(20)) AS entrada_saida
  ,to_date(data, 'DD/MM/YYYY') AS data
  ,cast(movimentacao as varchar(100)) AS movimentacao
  ,cast(produto as varchar(200)) AS produto_dsc
  ,split_part(cast(produto as varchar(200)), ' - ', 1) AS produto
  ,cast(instituicao as varchar(100)) AS instituicao
  ,cast(quantidade as numeric(15,2)) AS quantidade
  ,cast(NULLIF(preco_unitario, '-') as numeric(15,2)) AS preco_unitario
  ,cast(NULLIF(valor_da_operacao, '-') as numeric(15,2)) AS valor_da_operacao
  ,cast(path as varchar(500)) AS path
FROM ingest_bov;