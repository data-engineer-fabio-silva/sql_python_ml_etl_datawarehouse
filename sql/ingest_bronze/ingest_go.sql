DROP TABLE IF EXISTS public.ingest_go;
CREATE TABLE public.ingest_go (
	"date" VARCHAR(50)
	,atv_natv VARCHAR(10)
	,in_out VARCHAR(10)
	,category_nm VARCHAR(100)
	,price VARCHAR(50)
	,total VARCHAR(50)
	,description VARCHAR(500)
	,"path" VARCHAR(500)
);