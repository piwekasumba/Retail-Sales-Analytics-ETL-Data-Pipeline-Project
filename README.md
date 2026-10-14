# Retail Sales Analytics ETL Data Pipeline

A self-directed PostgreSQL portfolio project focused on **SQL data preparation, transformation, data quality and reporting-ready retail data**.

This project explores how raw retail data can be organised and prepared for downstream analysis. It complements my RetailMart reporting project, which focuses more directly on SQL-based reporting, KPI validation and interpretation.

**Project focus:** PostgreSQL · SQL · Data Preparation · ETL Concepts · Data Quality · Retail Reporting

---

## Project Overview

Reliable reporting depends on more than writing a query. Source data must be structured appropriately, related records must be joined correctly, and transformations must preserve the meaning of the underlying information.

This project practises a simplified SQL-based workflow for moving from source data towards a structured dataset for analysis.

```text
Source Data
    ↓
Extract
    ↓
Prepare and Transform
    ↓
Structure Data in PostgreSQL
    ↓
Reporting Dataset
    ↓
Business Analysis
```

The workflow is intended for learning and portfolio demonstration. It is not presented as a production data pipeline.

## Project Objective

The objective is to practise how PostgreSQL and SQL can support the preparation of retail data for analysis and reporting.

The project focuses on:

- Reviewing source data and its structure
- Selecting and preparing relevant fields
- Applying SQL transformations
- Joining and aggregating related information
- Organising data for downstream queries
- Considering data-quality issues that may affect reporting
- Connecting data preparation to business reporting questions

## Business Context

Retail and FMCG reporting can involve information about sales transactions, products, stores, customers, employees and reporting periods.

If these data elements are inconsistent or incorrectly combined, the resulting totals and comparisons may be misleading.

This project uses a simulated retail dataset to practise the preparation stage that can support questions such as:

- What does overall sales activity look like?
- How can sales be summarised by product or store?
- How can transaction dates support period-based analysis?
- How can related data be combined for reporting?
- What source-data issues should be considered before interpreting results?

These are reporting use cases for the project, not claims about work performed for a real company.

## Dataset

The project uses **simulated retail sales data** for learning and portfolio purposes. It does not represent a real company's operational data.

The source-data file supplied in the repository is:

```text
Retail_sales_data_pipeline/1.Data/retail_sales_raw.csv.txt
```

The `.txt` extension is part of the filename currently recorded in the repository.

## Tools and Technologies

- **PostgreSQL 18** — relational database environment
- **SQL** — querying, filtering, transformation and aggregation
- **Relational data concepts** — working with structured data and relationships
- **ETL concepts** — extract, transform and load
- **Data-quality awareness** — considering missing, duplicate, inconsistent or unexpected data

The project is focused on SQL and PostgreSQL. It does not claim experience with cloud platforms, enterprise orchestration tools or production data-engineering systems.

## Workflow

### 1. Extract and review source data

Start with the supplied retail source file and review the available fields and records.

The aim is to understand the starting data before applying transformations.

### 2. Prepare the data

Consider whether the source data is suitable for the intended analysis.

Relevant considerations include:

- Missing or unexpected values
- Duplicate or unexpected records
- Data types and date handling
- Consistency of category values
- Relationships between related records

The checks that can be demonstrated depend on the SQL scripts and source data included in the repository.

### 3. Transform with SQL

Use the available SQL scripts to practise preparing data for analysis. Depending on the script, this may involve selecting fields, filtering records, joining related data, grouping records and calculating aggregate measures.

Transformations should preserve the intended meaning of the data and support the reporting question being asked.

### 4. Structure data in PostgreSQL

Organise the prepared data in PostgreSQL so it can be queried consistently.

The resulting structures provide a basis for further analysis, subject to the logic implemented in the scripts.

### 5. Connect preparation to reporting

The prepared data is intended to support downstream retail analysis. The reporting question determines which fields, transformations and aggregations are needed.

The key idea is that data preparation and reporting are connected: a result is only useful when the underlying data and comparison are appropriate for the question.

## Data Quality and Reporting Considerations

The project provides an opportunity to examine how data preparation can affect reporting reliability.

|   Consideration   |                     Why it matters                             |
|-------------------|----------------------------------------------------------------|
| Missing values    | Important fields may be unavailable for some records.          |
| Duplicate records | Repeated records can inflate counts or totals.                 |
| Join accuracy     | Incorrect join conditions can multiply rows.                   |
| Data consistency  | Inconsistent categories can split otherwise related results.   |
| Date handling     | Incorrect date treatment can affect period-based comparisons.  |
| Aggregation       | Totals and averages must match the intended level of analysis. |

These are the issues the project is designed to explore. The presence of a topic in this table does not, by itself, mean every check has been implemented or passed. The SQL scripts should be reviewed to establish what is actually tested.

## Business Questions and Reporting Purpose

|            Business question                   |               Relevant SQL approach                      |        Reporting purpose            |
|------------------------------------------------|----------------------------------------------------------|-------------------------------------|
| What is overall sales activity?                | Aggregate relevant sales records                         | Summarise sales measures            |
| Which products have stronger sales?            | Group and aggregate by product                           | Compare product performance         |
| How does sales activity differ by store?       | Join and aggregate relevant records                      | Compare locations                   |
| How does activity vary by period?              | Use transaction dates and period-based grouping          | Examine changes over time           |
| How can source data be prepared for reporting? | Apply the available preparation and transformation steps | Structure data for analysis         |
| How can related business data be combined?     | Join relevant data using appropriate keys                | Support broader reporting questions |

These questions describe the intended analytical use cases. The available outputs depend on the data fields and SQL logic actually implemented in the repository.

## Project Structure

The repository currently contains the following structure:


Retail-Sales-Analytics-ETL-Data-Pipeline-Project
│
├── README.md
│
└── Retail_sales_data_pipeline
    ├── 1.Data
    ├── 1.SQL-Commit-1
    ├── 2.SQL-Commit-2
    ├── 3.SQL-Commit-3
    ├── 4.SQL-Commit-4
    └── 5.SQL-Commit-5


### Source data


1.Data
└── retail_sales_raw.csv.txt


### First SQL stage

1.SQL-Commit-1
├── 01_create_tables.sql.txt
├── 02_clean_data.sql.txt
├── 03_transform_data.sql.txt
├── 04_analysis_queries.sql.txt
└── PostgreSQL-SQL-Queries.sql


The remaining numbered SQL-stage directories are retained as they currently exist in the repository. Their contents should be reviewed directly rather than inferred from their directory names.

## How to Review the Project

A recruiter, hiring manager or analyst can review the project in this order:

1. Read this README to understand the purpose and scope.
2. Inspect the source data in `1.Data`.
3. Review the SQL files in their numbered stages.
4. Follow the implemented preparation and transformation logic.
5. Inspect the analysis queries and available outputs.
6. Check which data-quality controls are implemented and what their results show.

The purpose of this review is to understand the SQL workflow and the reasoning behind preparing data for reporting.

## How to Run

The repository contains source data and SQL files. To reproduce the workflow:

1. Install PostgreSQL and open a suitable PostgreSQL client.
2. Create a separate database for the project.
3. Review the source file and the SQL scripts before running them.
4. Follow the numbered stages in order, checking dependencies between scripts.
5. Execute the relevant SQL in the project database.
6. Review the resulting tables, query outputs and any validation results.

**Important:** GitHub stores and displays the project files; committing a SQL file does not execute it. The exact execution order and any file-format adjustments must be confirmed from the scripts themselves. Do not assume that every script is ready to run unchanged in every environment.

## Portfolio Relationship

### Retail Sales Analytics ETL Data Pipeline

**Focus:** preparing and structuring data for downstream analysis.


Source Data
    ↓
Data Preparation
    ↓
SQL Transformation
    ↓
Structured Data


### RetailMart Executive Reporting SQL Project

**Focus:** using SQL to answer reporting questions, check measures and interpret results.


Business Question
    ↓
KPI Definition
    ↓
SQL Analysis
    ↓
Validation
    ↓
Reporting Interpretation


Together, the projects represent two related areas of SQL practice: preparing data for analysis and examining reporting results carefully.

## What This Project Demonstrates

This project provides portfolio evidence of my work with SQL and PostgreSQL concepts, including:

- Reviewing structured source data
- Writing and organising SQL scripts
- Practising data preparation and transformation
- Using joins, filters and aggregate queries where implemented
- Considering data-quality issues
- Connecting data preparation to reporting requirements

The repository and its SQL outputs should be used to assess the specific work completed. This is a self-directed learning project, not evidence of professional employment or production-system responsibility.

## Career Relevance

I am building a portfolio to pursue entry-level opportunities in South Africa, with a primary focus on Johannesburg and Gauteng and suitable remote roles across South Africa as an additional option.

Roles relevant to my current direction include:

- Junior Reporting Analyst
- Reporting Analyst
- Junior Data Analyst
- Junior Data and Reporting Analyst
- Entry-level SQL-focused reporting or data-quality roles

My main focus is **SQL → Reporting → Data Analysis → Data Quality**.

This project supports that direction by demonstrating practical SQL and data-preparation learning. It does not claim that I have already held one of these roles or have professional ETL or data-engineering experience.

## Limitations

This is a simulated, self-directed portfolio project. Its scope is limited to the data, SQL scripts and outputs included in the repository.

It is not presented as:

- A production data pipeline
- An enterprise ETL platform
- A cloud data-engineering implementation
- An automated, scheduled workflow
- A production monitoring or governance system
- Professional data-engineering employment

## About

I am a self-taught SQL learner developing practical skills in PostgreSQL, reporting, data preparation and data quality through independent portfolio projects.

My goal is to build credible, reviewable evidence of my SQL skills and progress towards an entry-level reporting or data analyst role.

**This project focuses on preparing data for analysis; my RetailMart project focuses more directly on reporting questions, KPI validation and interpretation.**


