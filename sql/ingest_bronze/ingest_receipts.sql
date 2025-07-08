DROP TABLE IF EXISTS public.ingest_receipts;
CREATE TABLE public.ingest_receipts (
	"date" VARCHAR(50)
	,receipt_number VARCHAR(100)
	,count_item VARCHAR(50)
	,cod_item VARCHAR(50)
	,description VARCHAR(100)
	,qtd_item VARCHAR(50)
	,qtd_unit VARCHAR(50)
	,value_unit VARCHAR(50)
	,value_tax VARCHAR(50)
	,value_item VARCHAR(50)
	,category VARCHAR(100)
	,name_item VARCHAR(100)
	,"path" VARCHAR(500)
);