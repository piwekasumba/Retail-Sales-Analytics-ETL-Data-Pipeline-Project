-- ============================================================
-- RETAIL SALES ANALYTICAL REPORTING QUERIES
-- PostgreSQL
--
-- Purpose:
-- Demonstrate how SQL can be used to generate reporting-ready
-- outputs that support sales monitoring and business decisions.
-- ============================================================


-- ============================================================
-- KPI REPORT
-- Total Revenue
--
-- Business Question:
-- What is the total revenue generated from all sales?
--
-- Business Purpose:
-- Provides a high-level sales KPI for management reporting.
-- ============================================================

SELECT
    SUM(total_sales) AS total_revenue
FROM sales_clean;



-- ============================================================
-- KPI REPORT
-- Monthly Revenue Trend
--
-- Business Question:
-- How has revenue changed over time?
--
-- Business Purpose:
-- Helps management monitor monthly sales performance and
-- identify growth or declining sales periods.
-- ============================================================

SELECT
    order_year,
    order_month,
    SUM(total_sales) AS monthly_revenue
FROM sales_clean
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;



-- ============================================================
-- SALES PERFORMANCE REPORT
-- Top 5 Products by Revenue
--
-- Business Question:
-- Which products generate the highest revenue?
--
-- Business Purpose:
-- Supports product performance reporting and helps identify
-- top revenue-generating products.
-- ============================================================

SELECT
    product_name,
    SUM(quantity) AS units_sold,
    SUM(total_sales) AS total_revenue
FROM sales_clean
GROUP BY
    product_name
ORDER BY
    total_revenue DESC
LIMIT 5;



-- ============================================================
-- SALES REPORT
-- Revenue by Product Category
--
-- Business Question:
-- Which product categories contribute the most revenue?
--
-- Business Purpose:
-- Supports category performance reporting and helps identify
-- areas contributing most to overall sales.
-- ============================================================

SELECT
    category,
    SUM(total_sales) AS category_revenue
FROM sales_clean
GROUP BY
    category
ORDER BY
    category_revenue DESC;



-- ============================================================
-- CUSTOMER REPORT
-- Top 5 Customers by Total Spending
--
-- Business Question:
-- Which customers have spent the most?
--
-- Business Purpose:
-- Supports customer value reporting and helps identify
-- high-value customers for business monitoring.
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(sc.order_id) AS total_orders,
    SUM(sc.total_sales) AS total_spent,
    ROUND(AVG(sc.total_sales), 2) AS average_order_value
FROM sales_clean AS sc
INNER JOIN customers AS c
    ON sc.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_spent DESC
LIMIT 5;



-- ============================================================
-- EXPORT REPORT
-- Top Customers
--
-- Purpose:
-- Export the customer spending report for use in dashboards,
-- reporting tools, or further business analysis.
-- ============================================================

COPY (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(sc.order_id) AS total_orders,
        SUM(sc.total_sales) AS total_spent,
        ROUND(AVG(sc.total_sales), 2) AS average_order_value
    FROM sales_clean AS sc
    INNER JOIN customers AS c
        ON sc.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
    ORDER BY
        total_spent DESC
    LIMIT 5
)
TO 'results/top_customers.csv'
WITH CSV HEADER;
