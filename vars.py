import utils
from dotenv import dotenv_values, find_dotenv
# import json

#### load environment variables
env_file_path = find_dotenv()

if env_file_path:

    env_file = dotenv_values(env_file_path)

    # database secrets
    # db_secrets = json.loads(env_file.get('db_secrets'))  

    db_secrets = {
        "dbname": env_file.get('db_postgres_nm'),
        "user": env_file.get('db_user_nm'),
        "password": env_file.get('db_password'),
        "host": env_file.get('db_postgres_host', 'localhost'), 
        "port": env_file.get('db_postgres_port', '5432')      
    }

    gx_connection_string = f"postgresql+psycopg2://{env_file.get('db_user_nm')}:{env_file.get('db_password')}@{env_file.get('db_postgres_host', 'localhost')}:{env_file.get('db_postgres_port', '5432')}/{env_file.get('db_postgres_nm')}"

    # windows source repository path
    win_path_plan_fin = env_file.get('win_path_plan_fin')

    # root data repository path
    path_base = utils.create_path(win_path_plan_fin, 'google_drive\p_p_f\p_p_f',)

    # data sources folders path
    path_dir_me = utils.create_path(path_base, 'me')
    path_dir_go = utils.create_path(path_base, 'go')
    path_dir_salary = utils.create_path(path_base, 'salary')
    path_dir_bov = utils.create_path(path_base, 'bov')
    path_dir_tables = utils.create_path(path_base, 'tables')
    path_dir_legacy_tables = utils.create_path(path_dir_tables, 'legacy_tables')
    path_dir_bank_cards = utils.create_path(path_base, 'bank_cards')
    path_dir_receipts = utils.create_path(path_base, 'receipts')

    # tables name definition
    table_nm_me = env_file.get('table_nm_me')
    table_nm_go = env_file.get('table_nm_go')
    table_nm_salary = env_file.get('table_nm_salary')
    table_nm_bov = env_file.get('table_nm_bov')
    table_nm_legacy_fact = env_file.get('table_nm_legacy_fact')
    table_nm_bank_cards = env_file.get('table_nm_bank_cards')
    table_nm_receipts = env_file.get('table_nm_receipts')

    # sql folder paths
    stg_silver_sql_paths = env_file.get('stg_silver_sql_paths')
    consumption_gold_sql_path = env_file.get('consumption_gold_sql_path')    

    path_dir_stg_silver = utils.create_path(win_path_plan_fin, stg_silver_sql_paths)
    parh_dir_consumption_gold = utils.create_path(win_path_plan_fin, consumption_gold_sql_path)
else:
    print("No .env file found")