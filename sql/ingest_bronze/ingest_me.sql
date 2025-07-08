DROP TABLE IF EXISTS public.ingest_me;
CREATE TABLE public.ingest_me (
	"date" VARCHAR(50)
	,atv_natv VARCHAR(10)
	,category_nm VARCHAR(100)
	,price VARCHAR(50)
	,total VARCHAR(50)
	,description VARCHAR(500)
	,"path" VARCHAR(500)
);