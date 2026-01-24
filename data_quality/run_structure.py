import sys
import os

import great_expectations as gx
import great_expectations.expectations as gxe
import yaml

import gx_utils

# Add root directory to sys.path
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

import vars

# If flag equals False, execute just check points.
# Else create: data source, asset, batch, expectation suite and validation definitions
flag_create_gx_structure = False

# Path to secret variables
yaml_config_path = vars.gx_config_variables_file

# Get postgres connection string
postgres_gx_connection_str = vars.postgres_gx_connection_str

# Define a Data Context
gx_context = gx.get_context(mode='file')

if flag_create_gx_structure:
    # open yaml file
    with open(yaml_config_path, 'r', encoding='utf-8') as f:
        yaml_gx_configs_file = yaml.safe_load(f)

    # creating gx structure
    for collections, collections_gx_vars in yaml_gx_configs_file['collection'].items():

        print(f'\nCreating {collections} structure')

        # get or add a postgres data source
        data_source = gx_utils.get_or_create_data_source(gx_context, collections_gx_vars['data_source_nm'], postgres_gx_connection_str)

        # get or add a data asset
        asset = gx_utils.get_or_create_data_asset(data_source, collections_gx_vars['asset_nm'], collections_gx_vars['asset_table_nm'])

        # get or add a batch definition
        batch_def = gx_utils.get_or_create_batch_definition(asset, collections_gx_vars['batch_def_nm'])

        # get or add a expectation suite
        expec_suite = gx_utils.get_or_create_expectation_suite(gx_context, collections_gx_vars['expec_suite_nm'])

        # Limpar expectations existentes para evitar duplicatas
        if expec_suite.expectations:
            print(f"  Clearing {len(expec_suite.expectations)} existing expectations")
            
            expec_suite.expectations.clear() # expec_suite.expectations = []

            gx_context.suites.add_or_update(expec_suite)

        # Add expectations dynamically
        for exp_cfg in collections_gx_vars["expectations"]:
            exp_type = exp_cfg.pop("type")
            expectation_class = getattr(gxe, exp_type)
            expectation = expectation_class(**exp_cfg)
            expec_suite.add_expectation(expectation)

        # get or add a validation definition
        validation_def = gx_utils.get_or_create_validation_definition(gx_context, expec_suite, batch_def, collections_gx_vars['validation_def_nm'])


stg_silver_validation_definitions = [
    vd.name
    for vd in gx_context.validation_definitions.all()
    if vd.name.startswith('stg')
]

print('List of stg_silver_validation_definitions: ', stg_silver_validation_definitions)

checkpoint_stg_silver_nm = "checkpoint stg silver"
checkpoint_stg_silver = gx_utils.get_or_create_checkpoint(gx_context, checkpoint_stg_silver_nm, stg_silver_validation_definitions)

checkpoint_stg_silver.run()

# # ========== Generate and open DATA DOCS ==========
# print("\nGenerating Data Docs...")
# gx_context.build_data_docs()

# print("Opening Data Docs on browser...")
# gx_context.open_data_docs()