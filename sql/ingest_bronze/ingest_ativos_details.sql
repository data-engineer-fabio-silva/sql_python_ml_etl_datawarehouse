DROP TABLE IF EXISTS public.ingest_ativos_details CASCADE;
CREATE TABLE public.ingest_ativos_details (
	ativo VARCHAR(100)
	,setor VARCHAR(100)
	,categoria VARCHAR(100)
);