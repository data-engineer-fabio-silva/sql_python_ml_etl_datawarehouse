# BRAINSTORM: Synthetic Data Generation

**Feature:** Synthetic Data Generator for Public Portfolio
**Date:** 2026-04-01
**Status:** Ready for /define
**Next Step:** `/define .claude/sdd/features/BRAINSTORM_SYNTHETIC_DATA.md`

---

## Problem Statement

The project contains real personal finance data (bank transactions, salary, investments, receipts).
This prevents safe public sharing on GitHub or use as a portfolio demo.
A synthetic data generator using Faker will replace all real data with realistic-but-fictional equivalents.

---

## Discovery Q&A

| # | Question | Answer |
|---|----------|--------|
| 1 | Which tables to cover? | All 9 bronze tables |
| 2 | Primary goal? | Safely share publicly — GitHub demo / portfolio |
| 3 | Volume and date range? | ~2 years, ~2,000–3,000 rows total |
| 4 | Ground truth samples available? | None — fully invent everything |
| 5 | CSV output needed? | Yes — support both CSV and direct DB insert |
| 6 | Include ingest_b (crypto)? | Yes — full realistic crypto trade rows |

---

## Selected Approach

**Single script with dual output mode** (`python/generate_synthetic_data.py`)

One script with one generator function per Bronze table.
Supports `--output db`, `--output csv`, or `--output both` via CLI argument.

### Rejected Alternatives

| Approach | Why Rejected |
|----------|--------------|
| One file per table (9 scripts) | Overkill for solo project; harder to run all at once |
| CSV-only output | Adds unnecessary indirection through ingest_files.py |

---

## YAGNI Cuts

- No Faker locale switching (pt_BR vs en_US mixed) — use fixed Brazilian conventions throughout
- No configurable seed for reproducibility — out of scope for MVP
- No schema validation against live DB — trust SQL DDL as source of truth
- No streaming/chunked inserts — row counts are small enough for simple bulk insert

---

## Table Coverage Plan

### Row Distribution (~2,000–3,000 total over 2 years: 2023-01-01 → 2024-12-31)

| Table | Est. Rows | Notes |
|-------|-----------|-------|
| ingest_bank_cards | 600 | ~25 transactions/month |
| ingest_go | 400 | ~17 expense entries/month |
| ingest_me | 300 | ~12 entries/month |
| ingest_legacy_fact | 400 | Historical combined, mixed categories |
| ingest_receipts | 500 | ~20 receipt line items/month |
| ingest_salary | 24 | 1 row/month (payroll) |
| ingest_bov | 150 | Stock trades, irregular frequency |
| ingest_ativos_details | 20 | Static lookup (ativo, setor, categoria) |
| ingest_b | 100 | Crypto trades (BTC, ETH pairs) |
| **Total** | **~2,495** | |

---

## Data Realism Rules Per Table

### ingest_bank_cards
- `date`: random date in range, format `YYYY-MM-DD` (VARCHAR)
- `in_out`: `'out'`
- `category_nm`: invented credit card companies (5 company names)
- `sub_category_nm`: just `'payment'`
- `qtd`: keep empty
- `price`: keep empty
- `total`: random values as string with comma decimal
- `status`: `'pago'` or `'pendente'`
- `description`: Faker-generated merchant-like names
- `path`: fake file path like `'data/synthetic/bank_cards_2023.csv'`

### ingest_go
- `date`: YYYY-MM-DD string
- `atv_natv`: `'1.0'` (active) or `'0.0'` (inactive), weighted 90/10
- `in_out`: `'in'` or `'out'`
- `category_nm`: similar categories to bank_cards
- `price` / `total`: comma-decimal strings
- `description`: short invented descriptions
- `path`: fake path

### ingest_me
- Same structure as ingest_go minus `in_out`
- `atv_natv`: weighted 90/10

### ingest_legacy_fact
- Similar to ingest_bank_cards with added `sub_category_nm`
- Must include rows where `category_nm = 'meta'` (used by vw_kpi_meta gold view)
- Must include rows where `category_nm LIKE '%cartão%'` (used by vw_kpi_card_total_month_year)

### ingest_receipts
- `date`: YYYY-MM-DD string
- `receipt_number`: fake alphanumeric receipt ID
- `count_item` / `cod_item`: sequential integers as strings
- `description` / `name_item`: grocery/household item names (Faker food + custom list)
- `qtd_item` / `qtd_unit`: numeric strings, unit codes like `'UN'`, `'KG'`, `'L'`
- `value_unit` / `value_item`: comma-decimal strings
- `value_tax`: sometimes `'nan'` (matches Silver NULLIF logic)
- `category`: grocery subcategories
- `online`: `'True'` or `'False'`
- `path`: fake path

### ingest_salary
- 24 rows (one per month, 2023–2024)
- `name`: single consistent fake name throughout (same "person")
- `worked_hours`: e.g., `'176'`
- `gross_salary`: consistent fake salary (e.g., R$7,500/month as string)
- `benefits`: fixed amount string
- `discounts`: ~25% of gross as string
- `net_salary`: gross + benefits - discounts as string
- `closing_date`: end of each month
- `invoice_status` / `paiment_status`: `'pago'`
- `company`: single fake company name
- `path`: fake path

### ingest_bov
- `entrada_saida`: `'Credito'` or `'Debito'`
- `data`: DD/MM/YYYY format (matches Silver TO_DATE)
- `movimentacao`: values from the set used in Gold filters: `'Transferência - Liquidação'`, `'Desdobro'`, `'Bonificação em Ativos'`
- `produto`: must reference tickers from `ingest_ativos_details` (foreign key consistency)
- `instituicao`: fake broker names
- `quantidade` / `preco_unitario` / `valor_da_operacao`: numeric strings, sometimes `'-'` for NULLIF handling
- `path`: fake path

### ingest_ativos_details
- 20 rows of invented Brazilian stock-like tickers (e.g., XPTO3, ABCD4)
- `setor`: Brazilian market sectors (financeiro, energia, tecnologia, saúde, consumo)
- `categoria`: `'ação'`, `'fii'`, `'etf'`

### ingest_b (Crypto)
- `Date(UTC)`: ISO datetime string
- `OrderNo`: fake alphanumeric order ID
- `Pair`: from set `['BTC/USDT', 'ETH/USDT', 'BTC/BRL', 'ETH/BRL']`
- `Type`: `'limit'` or `'market'`
- `Side`: `'buy'` or `'sell'`
- `Order Price` / `Average Price`: price strings per pair
- `Order Amount` / `Executed` / `Trading total`: numeric strings
- `Time`: timestamp string
- `Status`: `'Filled'` or `'Cancelled'` (weighted 90/10)
- `path`: fake path

---

## Script Design

```python
# python/generate_synthetic_data.py

import argparse
from faker import Faker
import random
import psycopg2
import csv
from pathlib import Path
from vars import ...  # existing DB config

fake = Faker('pt_BR')

DATE_START = date(2023, 1, 1)
DATE_END   = date(2024, 12, 31)

def generate_bank_cards(n=600) -> list[dict]: ...
def generate_go(n=400) -> list[dict]: ...
def generate_me(n=300) -> list[dict]: ...
def generate_legacy_fact(n=400) -> list[dict]: ...
def generate_receipts(n=500) -> list[dict]: ...
def generate_salary() -> list[dict]: ...       # fixed 24 rows
def generate_bov(n=150) -> list[dict]: ...
def generate_ativos_details() -> list[dict]:   # fixed 20 rows
def generate_b(n=100) -> list[dict]: ...

def insert_to_db(table: str, rows: list[dict], conn): ...
def write_to_csv(table: str, rows: list[dict], output_dir: Path): ...

def main(output: str):
    generators = {
        'ingest_ativos_details': generate_ativos_details(),
        'ingest_bank_cards':     generate_bank_cards(),
        'ingest_go':             generate_go(),
        'ingest_me':             generate_me(),
        'ingest_legacy_fact':    generate_legacy_fact(),
        'ingest_receipts':       generate_receipts(),
        'ingest_salary':         generate_salary(),
        'ingest_bov':            generate_bov(),
        'ingest_b':              generate_b(),
    }
    # truncate + insert OR write CSV OR both

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', choices=['db', 'csv', 'both'], default='both')
    args = parser.parse_args()
    main(args.output)
```

---

## Cross-Table Consistency Rules

1. **ingest_bov.produto** must only use tickers that exist in **ingest_ativos_details.ativo**
2. **ingest_legacy_fact** must include rows with `category_nm = 'meta'` and `category_nm LIKE '%cartão%'` so Gold views return data
3. **ingest_salary.name** must be the same fake name across all 24 rows
4. All `path` columns should use a consistent fake path pattern: `'data/synthetic/<table>_<year>.csv'`

---

## Output Artifacts

| Mode | Output |
|------|--------|
| `--output db` | Truncates all 9 tables, inserts fresh synthetic rows |
| `--output csv` | Writes `data/synthetic/<table>.csv` (one file per table) |
| `--output both` | Does both |

---

## Draft Requirements (for /define)

1. Script must generate ~2,495 rows across all 9 Bronze tables
2. Date range: 2023-01-01 to 2024-12-31
3. Data must be in the raw VARCHAR format expected by Bronze tables (comma decimals, string dates, 'nan' nulls)
4. Cross-table consistency: bov tickers must reference ativos_details; legacy_fact must feed Gold KPI filters
5. Must support `--output db`, `--output csv`, `--output both`
6. DB insert must truncate tables before inserting (idempotent re-run)
7. CSV output must go to `data/synthetic/` directory
8. Uses Faker (`pt_BR` locale) + Python stdlib `random` only — no new heavy dependencies
9. Must follow existing project conventions (`vars.py` for config, `try/except` error handling)
10. `data/synthetic/` directory must be added to `.gitignore`
