DROP TABLE IF EXISTS public.ingest_bank_cards;
CREATE TABLE public.ingest_bank_cards (
	"date" VARCHAR(50)
	,in_out VARCHAR(10)
	,category_nm VARCHAR(50)
	,sub_category_nm VARCHAR(100)
	,qtd VARCHAR(50)
	,price VARCHAR(50)
	,total VARCHAR(50)
	,status VARCHAR(50)
	,description VARCHAR(500)
	,"path" VARCHAR(500)
);