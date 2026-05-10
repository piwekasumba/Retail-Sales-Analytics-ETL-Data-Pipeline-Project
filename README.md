# - Retail Sales SQL Pipeline -

This project is part of my SQL learning portfolio focused on building real-world data analysis and data engineering fundamentals using PostgreSQL.

This project focuses on using SQL to clean, transform, and analyse retail sales data.

---

## • Real-world Data Challenges

Retail sales data often contains:

- missing values  
- duplicate records  
- inconsistent formatting  
- raw transactional structure  

---

## • What I Worked On

In this project, I used SQL to simulate real data workflow tasks including:

- cleaning and preparing raw sales data  
- handling missing and inconsistent values  
- joining related datasets  
- performing aggregations for insights  
- calculating revenue metrics  

---

## • How I Approached It

I focused on understanding how raw transactional data becomes structured outputs that can be used for reporting and decision-making.

---

## • Tools Used

PostgreSQL  
SQL  
Git & GitHub  

---

## • Project Contents

- Data cleaning queries  
- Transformation queries  
- Sales aggregation queries  
- Basic analysis queries  

---

## • Example SQL Query

```sql
SELECT 
    product_id,
    SUM(quantity * price) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC;

