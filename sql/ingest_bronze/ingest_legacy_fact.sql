DROP TABLE IF EXISTS public.ingest_legacy_fact;
CREATE TABLE public.ingest_legacy_fact (
	"date" VARCHAR(50)
	,in_out VARCHAR(10)
	,category_nm VARCHAR(100)
	,sub_category_nm VARCHAR(100)
	,qtd VARCHAR(50)
	,price VARCHAR(50)
	,total VARCHAR(50)
	,status VARCHAR(100)
	,description VARCHAR(500)
	,"path" VARCHAR(500)
);