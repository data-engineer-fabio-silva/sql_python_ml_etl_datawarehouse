import os
import pandas as pd
import psycopg2
from psycopg2 import sql # keep this import and psycopg2 due to errors
import unicodedata
import re
import vars

import warnings
warnings.simplefilter('ignore', UserWarning)

def find_excel_files(root_folder):

    excel_files = []
    for dirpath, dirnames, filenames in os.walk(root_folder):
        for file in filenames:
            if file.lower().endswith('.xlsx'):
                excel_files.append(os.path.join(dirpath, file))
    return excel_files

def insert_data(conn, df, file_path, TABLE_NAME):
    with conn.cursor() as cur:
        columns = list(df.columns) + ['path']
        values_template = ', '.join(['%s'] * len(columns))

        insert_query = sql.SQL(f"""
            INSERT INTO {TABLE_NAME} ({', '.join(columns)})
            VALUES ({values_template})
        """)

        for idx, row in df.iterrows():
            data = list(row.values) + [file_path]
            cur.execute(insert_query, data)
        conn.commit()

def clean_text(texto):

    texto = unicodedata.normalize('NFKD', texto).encode('ASCII', 'ignore').decode('utf-8')
    
    texto = re.sub(r'[^\w]', '_', texto)
    return texto

def exec(conn, files, TABLE_NAME):
    
    if not files:
        print('No .xlsx files found !')
        return
    
    with conn.cursor() as cur:
        cur.execute(f"""TRUNCATE TABLE {TABLE_NAME}""")
        conn.commit()

    for file_path in files:
        try:
            df = pd.read_excel(file_path, engine='openpyxl')
            df = df.astype(str)
            
            cleaned_columns = [clean_text(col) for col in df.columns]

            df = df.rename(columns = dict(zip(df.columns, cleaned_columns)))
            
            insert_data(conn, df, file_path, TABLE_NAME)
            print(f'File loaded: {file_path}')
        except Exception as e:
            print(f'Error processing {file_path}: {e}')

def main():

    DB_SECRETS = vars.db_secrets

    conn = psycopg2.connect(**DB_SECRETS)
 
    try:
        me_files = find_excel_files(vars.path_dir_me)
        exec(conn, me_files, vars.table_nm_me)
        ####
        go_files = find_excel_files(vars.path_dir_go)
        exec(conn, go_files, vars.table_nm_go)
        ####
        salary_files = find_excel_files(vars.path_dir_salary)
        exec(conn, salary_files, vars.table_nm_salary)
        ####
        bov_files = find_excel_files(vars.path_dir_bov)
        exec(conn, bov_files, vars.table_nm_bov)
        ####
        legacy_fact_files = find_excel_files(vars.path_dir_legacy_tables)
        exec(conn, legacy_fact_files, vars.table_nm_legacy_fact)
        ####        
        bank_cards_files = find_excel_files(vars.path_dir_bank_cards)
        exec(conn, bank_cards_files, vars.table_nm_bank_cards)
        ####        
        receipts_files = find_excel_files(vars.path_dir_receipts)
        exec(conn, receipts_files, vars.table_nm_receipts)

    finally:
        conn.close()

if __name__ == "__main__":
    main()