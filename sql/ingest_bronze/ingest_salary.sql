DROP TABLE IF EXISTS public.ingest_salary CASCADE;
CREATE TABLE public.ingest_salary (
	"name" VARCHAR(50)
	,worked_hours VARCHAR(50)
	,gross_salary VARCHAR(50)
	,benefits VARCHAR(50)
	,discounts VARCHAR(50)
	,closing_date VARCHAR(50)
	,net_salary VARCHAR(50)
	,invoice_status VARCHAR(50)
	,paiment_status VARCHAR(50)
	,company VARCHAR(50)
	,"path" VARCHAR(500)
);