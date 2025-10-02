import sys
import os

# Add root directory to sys.path
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

import vars
import great_expectations as gx
import great_expectations.expectations as gxe

def get_or_create_datasource(context, name, connection_string):
    try:
        return context.data_sources.get(name)
    except Exception:
        return context.data_sources.add_postgres(name, connection_string=connection_string)

def get_or_create_data_asset(datasource, asset_name, table_name):
    try:
        return datasource.get_asset(asset_name)
    except Exception:
        return datasource.add_table_asset(name=asset_name, table_name=table_name)
# ========== config ==========
gx_connection_string = vars.gx_connection_string
context = gx.get_context(mode="file")

# Access GX variables
column_name = context.config_variables.get("column_name")
valid_values = context.config_variables.get("valid_values")
asset_name = context.config_variables.get("asset_name")
datasource_name = context.config_variables.get("datasource_name")
table_name = context.config_variables.get("table_name")

# Get or create datasource e data asset
datasource = get_or_create_datasource(context, datasource_name, gx_connection_string)
data_asset = get_or_create_data_asset(datasource, asset_name, table_name)

# ========== Create EXPECTATION SUITE ==========
suite_name = "my_validation_suite"
try:
    suite = context.suites.get(suite_name)
    print(f"Suite '{suite_name}' found")
except Exception:
    suite = context.suites.add(gx.ExpectationSuite(name=suite_name))
    print(f"Suite '{suite_name}' created")

expectation = gxe.ExpectColumnValuesToBeInSet(
    column=column_name,
    value_set=valid_values
)

suite.add_expectation(expectation)
# Save a suite
context.suites.add_or_update(suite)
print(f"Suite saved with {len(suite.expectations)} expectation(s)")

# ========== Create a BATCH DEFINITION ==========
batch_definition_name = "My_Batch_Definition"
try:
    batch_definition = data_asset.get_batch_definition(batch_definition_name)
    print(f"Batch definition '{batch_definition_name}' found")
except Exception:
    batch_definition = data_asset.add_batch_definition_whole_table(batch_definition_name)
    print(f"Batch definition '{batch_definition_name}' created")

# ========== Create VALIDATION DEFINITION ==========
validation_def_name = "my_validation_def"

# If exist remove old validation
try:
    context.validation_definitions.delete(validation_def_name)
    print(f"Old Validation definition '{validation_def_name}' removed")
except Exception:
    pass

# Create and add validation definition to the context
validation_definition = gx.ValidationDefinition(
    name=validation_def_name,
    data=batch_definition,
    suite=suite
)

context.validation_definitions.add(validation_definition)
print(f"Validation definition '{validation_def_name}' added to context")

# ========== Create CHECKPOINT ==========
checkpoint_name = "my_checkpoint"

# Remove old checkpoint if exist
try:
    context.checkpoints.delete(checkpoint_name)
    print(f"Old Checkpoint '{checkpoint_name}' removed")
except Exception:
    pass

# Create checkpoint with a validation definition already added
checkpoint = gx.Checkpoint(
    name=checkpoint_name,
    validation_definitions=[validation_definition]
)

context.checkpoints.add(checkpoint)
print(f"Checkpoint '{checkpoint_name}' created")

# ========== Execute validations using CHECKPOINT ==========
print("\nExecuting validation with checkpoint...")

# Checkpoint automatically save results!
# checkpoint_result = context.run_checkpoint(checkpoint_name=checkpoint_name)

checkpoint = context.checkpoints.get(checkpoint_name)
checkpoint_result = checkpoint.run()
# ========== Generate and open DATA DOCS ==========
print("\nGenerating Data Docs...")
context.build_data_docs()

print("Opening Data Docs on browser...")
context.open_data_docs()

print("\Done! The report was opened with the validations results.")
print(f"Path: great_expectations/uncommitted/data_docs/local_site/index.html")
print(f"\nTips: You can execute again with: context.run_checkpoint('{checkpoint_name}')")