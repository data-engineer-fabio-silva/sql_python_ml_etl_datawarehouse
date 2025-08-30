import psycopg2
from collections import defaultdict, deque
import os
import utils
import vars

# Path where the SQL script of views are salved
SQL_SCRIPT_PATHS = [vars.path_dir_stg_silver, vars.parh_dir_consumption_gold]

# Function to load the content of SQL script
def load_sql_script(view_name):

    for path in SQL_SCRIPT_PATHS:
        filepath = os.path.join(path, f"{view_name}.sql")
        # print('filepath', filepath)
        if os.path.isfile(filepath):
            with open(filepath, 'r', encoding='utf-8') as f:
                return f.read()
    # If file not found in any configured path
    raise FileNotFoundError(f"SQL script '{view_name}.sql' not found in any configured path.")

# Database conection
DB_SECRETS = vars.db_secrets

conn = psycopg2.connect(**DB_SECRETS)
cur = conn.cursor()

# Search dependencies
cur.execute("""
    SELECT object_name, depends_on
    FROM metadata_object_dependencies
    WHERE object_type = 'view' and depends_on_type != 'table'
""")

dependencies = cur.fetchall()

# Buid do graph dependence
graph = defaultdict(list)
in_degree = defaultdict(int)
views = set()

for obj, dep in dependencies:
    graph[dep].append(obj)
    in_degree[obj] += 1
    views.add(obj)
    views.add(dep)

# Views without dependece (entry degree 0)
queue = deque([v for v in views if in_degree[v] == 0])
ordered_views = []

# Topology ordenation
while queue:
    view = queue.popleft()
    ordered_views.append(view)
    for neighbor in graph[view]:
        in_degree[neighbor] -= 1
        if in_degree[neighbor] == 0:
            queue.append(neighbor)

print('ordered_views', ordered_views)

# Drop views in reverse order
for view in reversed(ordered_views):
    print(f"Dropping view: {view}")
    try:
        cur.execute(f'DROP VIEW IF EXISTS {view};')
        conn.commit()
    except Exception as e:
        print(f"Failed to drop {view}: {e}")
        conn.rollback()

# Recreate views in the right order
for view in ordered_views:
    print(f"Recreating view: {view}")
    try:
        sql = load_sql_script(view)
        cur.execute(sql)
        conn.commit()
    except Exception as e:
        print(f"Failed to recreate {view}: {e}")
        conn.rollback()

# Finish
cur.close()
conn.close()
print("View recreation completed.")