
-- =========================================================
-- ANALYTICAL QUERIES (POSTGRESQL)
-- Retail Sales Data Pipeline
--
-- Purpose:
-- Use SQL to answer basic retail reporting questions
-- using the cleaned sales dataset.
--
-- Skills demonstrated:
-- 1. Aggregate sales calculations
-- 2. Monthly sales reporting
-- 3. Product and category performance
-- 4. Customer sales analysis using a JOIN
--
-- Note:
-- This is a self-directed project using project data.
-- The queries produce reporting outputs; they do not
-- establish business causes or predict future results.
-- =========================================================


-- =========================================================
-- QUERY 01: OVERALL REVENUE
--
-- Business question:
-- What is the total recorded sales value?
--
-- Reporting purpose:
-- Provides an overall sales figure for a reporting
-- period represented by the available dataset.
--
-- Output:
-- One row containing total recorded sales value.
-- =========================================================

SELECT
    SUM(total_sales) AS total_revenue
FROM sales_clean;


-- =========================================================
-- QUERY 02: MONTHLY REVENUE
--
-- Business question:
-- How does recorded sales value vary by month?
--
-- Reporting purpose:
-- Supports monthly sales monitoring and comparison
-- across the years represented in the dataset.
--
-- Output:
-- One row per year and month, ordered chronologically.
-- =========================================================

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


-- =========================================================
-- QUERY 03: TOP FIVE PRODUCTS BY REVENUE
--
-- Business question:
-- Which products have the highest recorded sales value?
--
-- Reporting purpose:
-- Summarises product-level sales and units sold.
--
-- Output:
-- Up to five products, ranked by recorded sales value.
-- =========================================================

SELECT
    product_name,
    SUM(quantity) AS total_units_sold,
    SUM(total_sales) AS total_revenue
FROM sales_clean
GROUP BY
    product_name
ORDER BY
    total_revenue DESC,
    product_name ASC
LIMIT 5;


-- =========================================================
-- QUERY 04: REVENUE BY PRODUCT CATEGORY
--
-- Business question:
-- How is recorded sales value distributed across
-- product categories?
--
-- Reporting purpose:
-- Supports category-level sales reporting and comparison.
--
-- Output:
-- One row per category, ordered by recorded sales value.
-- =========================================================

SELECT
    category,
    SUM(total_sales) AS category_revenue
FROM sales_clean
GROUP BY
    category
ORDER BY
    category_revenue DESC,
    category ASC;


-- =========================================================
-- QUERY 05: TOP FIVE CUSTOMERS BY SALES VALUE
--
-- Business question:
-- Which customers have the highest recorded sales value?
--
-- Reporting purpose:
-- Demonstrates joining sales records to customer details
-- and aggregating sales at customer level.
--
-- Output:
-- Up to five customers, ranked by recorded sales value.
-- This measures sales value in the dataset; it does not
-- establish customer profitability or future value.
-- =========================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(sc.total_sales) AS total_spent
FROM sales_clean AS sc
INNER JOIN customers AS c
    ON sc.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_spent DESC,
    c.customer_id ASC
LIMIT 5;

