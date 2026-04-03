# Data Warehouse Documentation (Medallion Architecture)

This repository follows the Medallion Architecture design pattern consisting of three layers:

* Bronze Layer (Raw Data)
* Silver Layer (Cleaned and Transformed Data)
* Gold Layer (Business-Ready Data)

---

# Bronze Layer

## Purpose

The Bronze layer stores raw data exactly as received from source systems.

## Characteristics

* No transformations (or minimal)
* Schema as close to source as possible
* Append-only (historical data preserved)
* Used for auditing and debugging

## Example Tables

* crm_customers
* crm_products
* crm_sales_details

## Key Operations

* Data ingestion (ETL/ELT pipelines)
* File loads (CSV)

## Notes

* Data may contain duplicates, nulls, inconsistencies
* No business logic applied

---

# Silver Layer

## Purpose

The Silver layer stores cleaned, validated, and transformed data.

## Characteristics

* Data cleaning (remove nulls, duplicates)
* Standardized formats (dates, naming)
* Data type corrections
* Basic joins and transformations

## Example Tables

* crm_sales_details (cleaned)
* crm_customers (standardized)

## Key Operations

* Data validation
* Deduplication
* Handling missing values
* Converting data types

## Quality Checks

* No duplicate primary keys
* Valid date formats
* No unexpected null values
* Referential integrity maintained

---

# Gold Layer

## Purpose

The Gold layer contains business-ready, analytics-friendly data models.

## Characteristics

* Aggregated data
* Star/Snowflake schema
* Optimized for BI tools (Power BI, Tableau)

## Example Tables / Views

* dim_customers
* dim_products
* fact_sales

## Key Operations

* Aggregations (SUM, COUNT, etc.)
* Business logic implementation
* KPI calculations

## Example Query

```sql
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name;
```

## Quality Checks

* No duplicate keys in dimensions
* Fact tables correctly linked to dimensions
* Aggregations validated

---

# Data Flow

Bronze -> Silver -> Gold

1. Bronze to Silver: Cleaning and transformation
2. Silver to Gold: Business modeling and aggregation

---

# Best Practices

* Use consistent naming conventions
* Maintain separate schemas (bronze, silver, gold)
* Automate pipelines using scheduled jobs
* Add data validation checks at each layer
* Document every transformation step



# Author

Aditya Chauhan

credit to: Data with barra

---

This documentation is designed for GitHub to clearly explain the data pipeline architecture.
