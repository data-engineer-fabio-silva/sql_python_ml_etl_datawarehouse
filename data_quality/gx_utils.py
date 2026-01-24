import great_expectations as gx

def get_or_create_data_source(gx_context, data_source_nm, postgres_gx_connection_str):
    """
    Retorna um datasource existente ou cria um novo.
    """
    try:
        data_source = gx_context.data_sources.get(data_source_nm)
        print(f"Datasource '{data_source_nm}' found")
        return data_source
    except Exception:
        data_source = gx_context.data_sources.add_postgres(
            data_source_nm, connection_string=postgres_gx_connection_str
        )
        print(f"Datasource '{data_source_nm}' created")
        return data_source

def get_or_create_data_asset(data_source, asset_nm, asset_table_nm):
    """
    Retorna um data asset existente ou cria um novo (table asset).
    """
    try:
        asset = data_source.get_asset(asset_nm)
        print(f"Data asset '{asset_nm}' found")
        return asset
    except Exception:
        asset = data_source.add_table_asset(
            name=asset_nm, table_name=asset_table_nm
        )
        print(f"Data asset '{asset_nm}' created")
        return asset

def get_or_create_batch_definition(data_asset, batch_def_nm):
    """
    Retorna um batch definition existente ou cria um novo (whole table).
    https://docs.greatexpectations.io/docs/reference/api/datasource/fluent/sql_datasource/TableAsset_class
    """
    try:
        batch_def = data_asset.get_batch_definition(batch_def_nm)
        print(f"Batch definition '{batch_def_nm}' found")
        return batch_def
    except Exception:
        batch_def = data_asset.add_batch_definition_whole_table(batch_def_nm)
        print(f"Batch definition '{batch_def_nm}' created")
        return batch_def

def get_or_create_expectation_suite(gx_context, expec_suite_nm):
    try:
        expec_suite = gx_context.suites.get(expec_suite_nm)
        print(f"Expectation suite '{expec_suite_nm}' found")
        return expec_suite
    except Exception:
        expec_suite_class = gx.ExpectationSuite(name=expec_suite_nm)
        expec_suite = gx_context.suites.add(expec_suite_class)
        print(f"Expectation suite '{expec_suite_nm}' created")
        return expec_suite

def get_or_create_validation_definition(gx_context=None, expec_suite=None, batch_def=None, validation_def_nm=None):
    """
    Retorna uma Validation Definition existente ou cria uma nova.
    """
    try:
        validation_def = gx_context.validation_definitions.get(validation_def_nm)
        print(f"Validation definition '{validation_def_nm}' found")
        return validation_def
    except Exception:
        validation_def = gx.ValidationDefinition(
             suite=expec_suite, data=batch_def, name=validation_def_nm
        )
        validation_def = gx_context.validation_definitions.add_or_update(validation_def)
        print(f"Validation definition '{validation_def_nm}' created")
        return validation_def

def get_or_create_checkpoint(gx_context, checkpoint_nm, validation_def):
    """
    Retorna um Checkpoint existente ou cria um novo.
    """
    try:
        checkpoint = gx_context.checkpoints.get(checkpoint_nm)
        print(f"Checkpoint '{checkpoint_nm}' found")
        return checkpoint
    except Exception:
        checkpoint_class = gx.Checkpoint(
            name=checkpoint_nm,
            validation_definitions=validation_def
        )
        checkpoint = gx_context.checkpoints.add(checkpoint_class)
        print(f"Checkpoint '{checkpoint_nm}' created")
        return checkpoint