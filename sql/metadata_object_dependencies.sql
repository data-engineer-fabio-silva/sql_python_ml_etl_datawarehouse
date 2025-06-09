CREATE TABLE public.metadata_object_dependencies (
	id serial4 NOT NULL
    ,object_name text NOT NULL
    ,object_type text NOT NULL
    ,depends_on text NULL
    ,depends_on_type text NULL
    ,last_updated timestamp NULL DEFAULT now()
    ,CONSTRAINT metadata_object_dependencies_pkey PRIMARY KEY (id)
);