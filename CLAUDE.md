# CLAUDE.md — sql_python_ml_etl_datawarehouse

## Project Overview

Personal finance data engineering project built with Medallion Architecture (Bronze → Silver → Gold).
Ingests financial data from CSV, XLSX, and APIs into PostgreSQL, transforms it through layered SQL pipelines,
and exposes insights via Metabase dashboards. Includes data quality checks with Great Expectations
and is evolving toward machine learning capabilities.

---

## Architecture

```
Raw Sources (CSV / XLSX / API)
        ↓
  Bronze Layer       → raw ingestion, no transformation (sql/ingest_bronze/)
        ↓
  Silver Layer       → cleansing, standardization, deduplication (sql/stage_silver/)
        ↓
  Gold Layer         → analytical models, fact/dim tables, reporting (sql/consumption_gold/)
        ↓
  Metabase           → dashboards and visualizations
```

---

## Repository Structure

```
sql_python_ml_etl_datawarehouse/
│
├── compose/                  # Docker Compose configs (PostgreSQL + Metabase)
├── data_quality/             # Great Expectations suites and checkpoints
├── docs/                     # Architecture diagrams, notes, glossary
│   ├── data_architecture.drawio.png
│   ├── glossary.md
│   └── notes.md
├── python/
│   ├── etl_legacy.py         # Legacy ETL code (to be EOL — do not modify)
│   ├── ingest_files.py       # Script for initial data load into Bronze tables
│   ├── recreate_views.py     # Script to recreate SQL view dependencies
│   └── api_cb.py             # Coinbase API ingestion (BTC-USD, BTC-BRL, USD-BRL) — dev only
├── sql/
│   ├── ingest_bronze/        # Raw ingestion SQL scripts
│   ├── stage_silver/         # Cleansing and transformation SQL scripts
│   ├── consumption_gold/     # Final analytical tables and views
│   └── metadata_object_dependencies.sql  # Tracks view dependency graph
├── utils.py                  # Shared utilities (path helpers, file listing)
├── vars.py                   # Shared variables and configuration constants
├── requirements.txt          # Python dependencies (Python 3.11.9)
├── .env                      # Environment variables (never commit secrets)
└── .gitignore
```

---

## Tech Stack

| Tool                  | Version / Notes                          |
|-----------------------|------------------------------------------|
| Python                | 3.11.9 (pinned due to GE dependency)     |
| PostgreSQL            | via Docker                               |
| Great Expectations    | 1.5.10 (pandas 2.1.4 locked upstream)    |
| Metabase              | via Docker                               |
| pandas                | 2.1.4 (do NOT upgrade — GE dependency)  |
| openpyxl              | 3.1.3                                    |
| psycopg2              | 2.9.9                                    |
| python-dotenv         | 1.0.1                                    |

> ⚠️ **Critical dependency lock**: `pandas==2.1.4` is pinned because Great Expectations has a hard upstream dependency on this version. Do NOT upgrade pandas without first validating GE compatibility.

> ⚠️ **Known issue — GE version conflict**: `requirements.txt` currently declares both `great-expectations==1.5.10` and `great_expectations[postgresql]==0.16.8`. These are incompatible versions of the same package. To be resolved before next environment setup.

---

## Common Commands

### Docker

```bash
# Start PostgreSQL
docker compose -f compose/docker-compose-postgres-metabase.yaml up -d

# Start Metabase
docker compose -f compose/docker-compose-metabase.yaml up -d

# Stop all services
docker compose -f compose/docker-compose-postgres-metabase.yaml down
docker compose -f compose/docker-compose-metabase.yaml down

# Check running containers
docker ps

# View PostgreSQL logs
docker logs <postgres_container_name>
```

### Python — Data Ingestion

```bash
# Install dependencies
pip install -r requirements.txt

# Run initial data load (Bronze layer)
python python/ingest_files.py

# Recreate views after schema changes
python python/recreate_views.py

# Run Coinbase API ingestion (dev only)
python python/api_cb.py
```

### Great Expectations — Data Quality

```bash
# Run a checkpoint
great_expectations checkpoint run <checkpoint_name>

# Open GE documentation site
great_expectations docs build

# List available suites
great_expectations suite list
```

### PostgreSQL (via psql or inside container)

```bash
# Connect to the database
psql -h localhost -U <user> -d <database>

# Run a SQL script
psql -h localhost -U <user> -d <database> -f sql/stage_silver/<script>.sql
```

---

## Coding Conventions

### General

- All identifiers in **snake_case** and **lowercase** — tables, columns, files, functions, variables
- Avoid abbreviations; prefer clarity over brevity (e.g., `transaction_date` not `txn_dt`)
- Secrets and credentials must always be loaded from `.env` via `python-dotenv` — never hardcoded

### Python

- Use `utils.py` for shared file/path helpers (`create_path`, `new_list_files`)
- Use `vars.py` for shared constants and configuration
- All scripts must handle exceptions explicitly with `try/except` and log meaningful errors
- Follow the existing pattern in `ingest_files/` when creating new ingestion scripts

### SQL

- Layer naming convention:
  - `bronze_<source>_<entity>` for raw ingestion tables
  - `silver_<entity>` for cleansed/standardized tables
  - `gold_<entity>` or `fact_<entity>` / `dim_<entity>` for analytical models
- Views should be created via scripts in `python/recreating_views/` to manage dependencies
- Always comment non-obvious SQL logic

### Git

- Branch naming: `plan-<number>` (e.g., `plan-12345`)
- Commit messages: descriptive, lowercase, present tense (e.g., `add silver transformation for credit card data`)
- Never commit `.env` or raw data files

---

## Data Layers — Detailed Behavior

### Bronze (Ingestion)
- Load data as-is from source (CSV, XLSX, API)
- No transformation — preserve original values including nulls and formatting
- Schema should reflect source structure faithfully

### Silver (Stage)
- Cleanse: fix nulls, normalize dates, standardize categories
- Deduplicate records
- Enforce data types and constraints
- GE validations should be applied at this layer

### Gold (Consumption)
- Build fact and dimension tables optimized for analytical queries
- Expose via Metabase-friendly views
- Aggregations and KPIs live here (expenses, savings, category totals)

---

## Data Quality (Great Expectations)

- Suites and checkpoints are stored in `data_quality/`
- Validations run against Silver layer data before Gold promotion
- When adding a new data source, always create a corresponding GE suite
- Key expectations to always include: `expect_column_to_exist`, `expect_column_values_to_not_be_null` (for key columns), `expect_column_values_to_be_of_type`

---

## What is WIP / Legacy

- `python/etl_legacy.py` — **Legacy ETL code, scheduled for EOL. Do NOT modify or extend.**
- `python/api_cb.py` — Coinbase API ingestion exists and is functional, but is **development only** — not yet promoted to production
- Machine learning models — planned but not yet implemented
- `compose/` — Docker configs may still be evolving

---

## Goals & Roadmap (for Claude Code context)

1. Evolve Silver transformations for better expense categorization
2. Promote API ingestion pipeline (`api_cb.py`) to production
3. Implement ML model for spending pattern prediction / anomaly detection
4. Improve GE coverage across all Silver tables
5. Automate pipeline execution (scheduling TBD)
6. Expand Metabase dashboards with savings and forecast views

---

## Important Warnings

- **Do NOT modify `python/etl_legacy.py`** — legacy code, to be decommissioned
- **Do NOT upgrade `pandas`** without verifying Great Expectations compatibility
- **Do NOT commit `.env`** — use `.env.example` for documentation if needed
- **Raw data files** (CSV/XLSX) should never be committed to the repository