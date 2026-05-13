# Retail Sales SQL Pipeline

This project is part of my SQL learning portfolio focused on building practical data analysis and data engineering fundamentals using PostgreSQL.

The project uses SQL to explore how raw retail sales data can be cleaned, transformed, and analysed into structured outputs for reporting and business insights.

---

## • Project Context

Retail sales data typically comes in raw transactional form and requires processing before it can be used for analysis.

This project focuses on simulating that process using SQL.

---

## • Real-world Data Challenges

Retail sales datasets often include:

- missing values  
- duplicate records  
- inconsistent formatting  
- transactional-level raw data  

---

## • What I Worked On

In this project, I used SQL to perform core data workflow tasks including:

- cleaning and preparing raw sales data  
- handling missing and inconsistent values  
- joining related datasets  
- aggregating data for sales insights  
- calculating revenue-related metrics  

---

## • How I Approached It

I focused on understanding how raw transactional data is transformed into structured outputs that can support reporting and basic business decision-making.

---

## • Tools Used

- PostgreSQL  
- SQL  
- Git & GitHub  

---

## • Project Contents

- Data cleaning queries  
- Data transformation queries  
- Sales aggregation queries  
- Revenue analysis queries  

---

## • Example SQL Query

```sql
SELECT 
    product_id,
    SUM(quantity * price) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC;

