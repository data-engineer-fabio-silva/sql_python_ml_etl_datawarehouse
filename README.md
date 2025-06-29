# 🚀 SQL and Python Project - Finance

This project demonstrates a sql and python solution solution focused on data enginieering, from a work in progress data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](docs/data_architecture.drawio.png)

1. **Ingestion/Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into Postgre Database.
2. **Stage/Silver Layer**: This layer includes data cleansing, standardization and processes to prepare data for analysis.
3. **Consumption/Gold Layer**: Tables ready for reporting and analytics.

---
# To Do
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

# Jira Backlog
### Task Id 
* 15 - Migrate code (WIP)
* 22 - Document queries

# Notes
* Before running the 'recreate_views' script, validate that the table/views is added to metadata_object_dependencies.