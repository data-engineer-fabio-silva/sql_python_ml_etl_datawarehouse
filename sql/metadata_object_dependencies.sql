CREATE TABLE public.metadata_object_dependencies (
	id SERIAL4 NOT NULL
    ,object_name TEXT NOT NULL
    ,object_type TEXT NOT NULL
    ,depends_on TEXT NULL
    ,depends_on_type TEXT NULL
    ,last_updated TIMESTAMP NULL DEFAULT NOW()
    ,CONSTRAINT metadata_object_dependencies_pkey PRIMARY KEY (id)
);