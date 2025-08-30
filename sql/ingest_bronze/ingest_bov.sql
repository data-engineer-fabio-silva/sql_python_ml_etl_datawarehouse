/*
================================================================================
Table Name: public.stg_bov
Author: [Your Name or Team Name]
Created: [YYYY-MM-DD]
Last Modified: [YYYY-MM-DD] by [Modifier's Name]
================================================================================

📌 Description:
This staging table serves as a raw data landing zone for BOV (stock exchange) 
transaction records. Data in this table is typically ingested from external 
sources (e.g., CSVs or APIs) and stored in text format for further parsing 
and transformation in downstream views like `vw_stg_bov`.

🔗 Dependencies:
- Consumed by: `public.vw_stg_bov`
- May serve as input to ETL processes or quality control checks

🗃️ Tables Used:
- This is a base table; it does not depend on other tables

================================================================================
*/
DROP TABLE IF EXISTS public.ingest_bov CASCADE;
CREATE TABLE public.ingest_bov (
	entrada_saida VARCHAR(50),
	"data" VARCHAR(50),
	movimentacao VARCHAR(100),
	produto VARCHAR(100),
	instituicao VARCHAR(100),
	quantidade VARCHAR(50),
	preco_unitario VARCHAR(50),
	valor_da_operacao VARCHAR(50),
	"path" VARCHAR(500)
);