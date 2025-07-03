# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
   - [Ingest/Bronze Rules](#ingest-bronze-rules)
   - [Stage/Silver Rules](#stage-silver-rules)
   - [Consumption/Gold Rules](#consumption-gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
4. [Stored Procedure](#stored-procedure-naming-conventions)
---

## **General Principles**

- **Naming Conventions**: Use snake_case, with lowercase letters and underscores (`_`) to separate words.
- **Language**: Use English for all names.
- **Avoid Reserved Words**: Do not use SQL reserved words as object names.

## **Table Naming Conventions**

### **Ingest/Bronze Rules**
- All names must start with the layer name, and table names must match their original names without renaming.
- **`<entity>_<sourcesystem>`**  
  - `<entity>`: Exact name from the source.  
  - `<sourcesystem>`: Name of the source (e.g., `me`, `go`).  
  - Example: `ingest_me` → Raw data from the ME source.

### **Stage/Silver Rules**
- All names must start with vw (view). Table names must match their original names without renaming.
- **`<vw>_<entity>_<sourcesystem>`** 
  - `<vw>`: View abbreviation.
  - `<entity>`: Exact name from the source.  
  - `<sourcesystem>`: Name of the source (e.g., `me`, `go`).  
  - Example: `vw_stage_me` → Transformed data from the ME source.

### **Consumption/Gold Rules**
- All names must use meaningful, business-aligned names.
- **`<vw>_<meaningful name>`** 
  - `<vw>`: View abbreviation.
  - `<meaningful name>`: Meaningful names that reflect the data's purpose (e.g., `card_totals`, `sectors`).  
  - Example: `vw_sectors` → Information ready to be consumed. 

### **Platinum Rules**
- WIP


#### **Glossary of Category Patterns**

| Pattern     | Meaning                           | Example(s)                              |
|-------------|-----------------------------------|-----------------------------------------|
| `dim_`      | Dimension table                  | `dim_customer`, `dim_product`           |
| `fact_`     | Fact table                       | `fact_sales`                            |
| `report_`   | Report table                     | `report_customers`, `report_sales_monthly`   |

## **WIP - Column Naming Conventions**

### **Surrogate Keys**  
- All primary keys in dimension tables must use the suffix `_key`.
- **`<table_name>_key`**  
  - `<table_name>`: Refers to the name of the table or entity the key belongs to.  
  - `_key`: A suffix indicating that this column is a surrogate key.  
  - Example: `customer_key` → Surrogate key in the `dim_customers` table.
  
### **Technical Columns**
- All technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column's purpose.
- **`dwh_<column_name>`**  
  - `dwh`: Prefix exclusively for system-generated metadata.  
  - `<column_name>`: Descriptive name indicating the column's purpose.  
  - Example: `dwh_load_date` → System-generated column used to store the date when the record was loaded.
 
## **WIP - Stored Procedure**

- All stored procedures used for loading data must follow the naming pattern:
- **`load_<layer>`**.
  
  - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.
  - Example: 
    - `load_bronze` → Stored procedure for loading data into the Bronze layer.
    - `load_silver` → Stored procedure for loading data into the Silver layer.