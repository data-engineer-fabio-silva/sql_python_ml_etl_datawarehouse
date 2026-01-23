## ⚠️ Warning

This section is a work-in-progress, and should not be considered official until this message is removed.

## To Do
* Migrate codes to this new repo
* Translate the code to english
* Migrate readme
* Migrate categorize_produto function
* Create dimentional diagram image
* Anonymize variables, function, paths names
* Reformulate raspberry setup readme
* Add folder struct on readme
* Unify fato_2023 and 24 in just one function
* Migrate sensitive data to .env
* Add code on sql folder

## Jira Backlog
#### Task Id 
* 15 - Migrate code (WIP)
* 22 - Document queries

## Notes
* Before running the 'recreate_views' script, validate that the table/views is added to metadata_object_dependencies.
* Currently it isn't feasible to automate the process of categorizing credit card transactions due to the variety of patterns in the transaction descriptions

# Python & SFTP Command Descriptions

## Python Package Management

- `pip install -r requirements.txt`  
  ➤ Installs all Python packages listed in `requirements.txt`.

- `pip install --upgrade psycopg2`  
  ➤ Upgrades the PostgreSQL adapter for Python to the latest version.

- `pip install --upgrade python-dotenv`  
  ➤ Upgrades the package used to load environment variables from `.env` files.

---

## SFTP (Secure File Transfer Protocol)

- `sftp user@ip`  
  ➤ Connects to a remote server via SFTP using the specified user and IP address.

- `pwd`  
  ➤ Shows the current directory on the remote server.

- `lpwd`  
  ➤ Shows the current directory on your local machine.

- `put -r <c:\folder path\>`  
  ➤ Recursively uploads a local folder to the remote server.

---

## Git config
* git config user.email "you@example.com"
* git config user.name "Your Name"

---

## First setup

- Download and install python 
  ➤ Verify the recommended version on requirements.txt file
  ➤ https://www.python.org/downloads/release/python-3119/
  ➤ Choose the option to add PATH and install

- Create or activate venv 
  ➤ python -m venv venv
  ➤ venv/Scritps/activate
  ➤ deactivate

- Install requirements
  ➤ `pip install -r requirements.txt`  
  ➤ Installs all Python packages listed in `requirements.txt`.

- Set .env 
  ➤ request to the project owner 

- Database/Backend setup
  ➤ WIP - run compose files to create the postgres database
  ➤ docker container is mandatory

- Create ingest and stage tables
  ➤ run creation script presente on sql/ingest_bronze and sql/stage_silve
  ➤ script automate the creation is a WIP

- Create and populate the metadata table
  ➤ request to the project owner

- Download the raw files  
  ➤ request to the project owner 

- Run the ingest code
  ➤ Run the ingest_files python code

- Run the recreate views code
  ➤ code to create sql/consumption_gold view