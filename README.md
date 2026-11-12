---
# Retail Sales Analytics ETL Pipeline — PostgreSQL SQL Project
---
## Project Overview

This is a self-directed PostgreSQL portfolio project that practises an ETL-style workflow using simulated retail sales data.

The project focuses on how raw and relational retail data can be structured, prepared and transformed into datasets intended for further analysis and reporting.

It demonstrates SQL-based data preparation concepts rather than a production-grade automated pipeline.
---
## Project Objectives

The project explores how to:

- Organise customer, product, order and order-item data.
- Define relational tables and key relationships.
- Prepare structured data for analysis.
- Apply SQL transformations and aggregations.
- Investigate missing, inconsistent or invalid values.
- Compare recorded order totals with calculated order-item values.
- Prepare reporting-oriented datasets.
---
## ETL Concepts

The project uses an ETL-style learning workflow:

1. Extract — work with the supplied simulated source data.
2. Transform — apply SQL logic to organise and prepare records.
3. Load — create or populate structured database tables for subsequent analysis.

The exact execution order and output table names should be followed as documented by the SQL scripts in this repository.
---
## Data Structure

The database design includes relational areas for:

- Customers
- Products
- Orders
- Order items
- Inventory

The inventory table represents a stock snapshot. It should not be interpreted as a historical stock-movement ledger.
---
## Data Quality and Reconciliation

A key focus is understanding whether the prepared data is suitable for downstream reporting.

Relevant checks include:

- Primary-key and foreign-key relationships
- Missing or unmatched records
- Duplicate and invalid values
- Row-count comparisons
- Recorded order totals compared with calculated order-item totals
- Consistent reporting grain before aggregation

A successful validation result should only be claimed when the relevant SQL check has actually been executed and reviewed.
---
## Tools

- PostgreSQL 18
- SQL
- pgAdmin 4
---
## Project Context and Limitations

This project uses simulated data and is independently developed for learning and portfolio demonstration.

It does not demonstrate a scheduled production pipeline, cloud data platform, enterprise orchestration, automated monitoring or professional data engineering experience.

Its purpose is to demonstrate foundational SQL data-preparation and ETL concepts relevant to reporting and analytics workflows.

