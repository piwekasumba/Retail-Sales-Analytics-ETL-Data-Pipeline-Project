
-- ============================================================
-- RETAIL SALES REPORTING QUERIES
-- PostgreSQL
--
-- Project type: Self-directed SQL reporting project
-- Data: Use the project's existing sales_clean and customers tables
--
-- Purpose:
-- Demonstrate SQL techniques used to calculate sales KPIs,
-- review performance trends, compare products and categories,
-- analyse customer spending, and prepare report-ready results.
--
-- Note:
-- These queries demonstrate reporting logic. Results should be
-- checked against the actual dataset before being presented as
-- verified business findings.
-- ============================================================


-- ============================================================
-- REPORT 01: TOTAL SALES KPI
--
-- Business question:
-- What is the total recorded sales value?
--
-- Reporting use:
-- Provides a high-level measure of sales across the records
-- included in the reporting dataset.
-- ============================================================

SELECT
    SUM(total_sales) AS total_revenue
FROM sales_clean;


-- ============================================================
-- REPORT 02: MONTHLY SALES TREND
--
-- Business question:
-- How much sales revenue was recorded in each month?
--
-- Reporting use:
-- Supports month-by-month monitoring and helps identify
-- changes in recorded sales over time.
--
-- Note:
-- This query assumes order_year and order_month are available
-- and correctly populated in sales_clean.
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
-- REPORT 03: TOP 5 PRODUCTS BY REVENUE
--
-- Business question:
-- Which products have the highest recorded sales revenue?
--
-- Reporting use:
-- Compares products using revenue and units sold.
-- ============================================================

SELECT
    product_name,
    SUM(quantity) AS units_sold,
    SUM(total_sales) AS total_revenue
FROM sales_clean
GROUP BY
    product_name
ORDER BY
    total_revenue DESC,
    product_name
LIMIT 5;


-- ============================================================
-- REPORT 04: SALES BY PRODUCT CATEGORY
--
-- Business question:
-- How is recorded sales revenue distributed across categories?
--
-- Reporting use:
-- Makes it easier to compare category-level sales performance.
-- ============================================================

SELECT
    category,
    SUM(total_sales) AS category_revenue
FROM sales_clean
GROUP BY
    category
ORDER BY
    category_revenue DESC,
    category;


-- ============================================================
-- REPORT 05: TOP 5 CUSTOMERS BY TOTAL SPENDING
--
-- Business question:
-- Which customers have the highest total recorded spending?
--
-- Reporting use:
-- Summarises order counts, total spending and average order
-- value for each customer.
--
-- Method:
-- First calculate sales at order level, then summarise orders
-- by customer. This avoids treating multiple order lines as
-- separate orders when an order contains multiple products.
-- ============================================================

WITH order_totals AS (
    SELECT
        customer_id,
        order_id,
        SUM(total_sales) AS order_total
    FROM sales_clean
    GROUP BY
        customer_id,
        order_id
),
customer_spending AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(order_total) AS total_spent,
        ROUND(AVG(order_total), 2) AS average_order_value
    FROM order_totals
    GROUP BY
        customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_orders,
    cs.total_spent,
    cs.average_order_value
FROM customer_spending AS cs
INNER JOIN customers AS c
    ON cs.customer_id = c.customer_id
ORDER BY
    cs.total_spent DESC,
    c.customer_id
LIMIT 5;


-- ============================================================
-- REPORT 06: EXPORT-READY TOP CUSTOMER RESULTS
--
-- Purpose:
-- Returns a clean result set that can be exported as CSV from
-- pgAdmin for further reporting or review.
--
-- Important:
-- This SELECT query does not create a CSV file by itself.
-- Use pgAdmin's result-grid export/save option to save the
-- results as a CSV file.
-- ============================================================

WITH order_totals AS (
    SELECT
        customer_id,
        order_id,
        SUM(total_sales) AS order_total
    FROM sales_clean
    GROUP BY
        customer_id,
        order_id
),
customer_spending AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(order_total) AS total_spent,
        ROUND(AVG(order_total), 2) AS average_order_value
    FROM order_totals
    GROUP BY
        customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_orders,
    cs.total_spent,
    cs.average_order_value
FROM customer_spending AS cs
INNER JOIN customers AS c
    ON cs.customer_id = c.customer_id
ORDER BY
    cs.total_spent DESC
LIMIT 5;


