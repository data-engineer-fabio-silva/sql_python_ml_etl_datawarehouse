DROP TABLE IF EXISTS public.ingest_b CASCADE;
CREATE TABLE public.ingest_b (
	"Date(UTC)" VARCHAR(50)
	,OrderNo VARCHAR(50)
	,Pair VARCHAR(50)
	,Type VARCHAR(50)
	,Side VARCHAR(50)
	,"Order Price" VARCHAR(50)
	,"Order Amount" VARCHAR(50)
	,Time VARCHAR(50)
	,Executed VARCHAR(50)
	,"Average Price" VARCHAR(50)
	,"Trading total" VARCHAR(50)
    ,"Status" VARCHAR(50)
	,"path" VARCHAR(500)
);