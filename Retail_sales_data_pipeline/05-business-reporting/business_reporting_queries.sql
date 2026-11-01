
-- =========================================================
-- ANALYTICAL QUERIES (POSTGRESQL)
-- Retail Sales Data Pipeline
--
-- Project context:
-- Self-directed SQL reporting project using project data.
--
-- Purpose:
-- Answer retail reporting questions using the cleaned
-- sales dataset and customer information.
--
-- Reporting areas:
-- 1. Overall recorded sales value
-- 2. Monthly sales reporting
-- 3. Product performance
-- 4. Category performance
-- 5. Customer sales analysis
-- 6. Customer join validation
--
-- Reporting definitions:
-- - Recorded sales value is the sum of total_sales.
-- - Monthly reporting uses the year and month fields
--   available in sales_clean.
-- - Customer sales value represents recorded sales
--   associated with each customer in the dataset.
--
-- Limitations:
-- These queries produce descriptive reporting outputs.
-- They do not establish business causes, profitability,
-- or future performance.
-- =========================================================


-- =========================================================
-- QUERY 01: OVERALL RECORDED SALES VALUE
--
-- Business question:
-- What is the total recorded sales value?
--
-- Reporting purpose:
-- Provides an overall sales figure for the available
-- dataset and its represented reporting period.
--
-- Output:
-- One row containing the total recorded sales value.
-- =========================================================

SELECT
    SUM(total_sales) AS total_recorded_sales_value
FROM sales_clean;


-- =========================================================
-- QUERY 02: MONTHLY RECORDED SALES VALUE
--
-- Business question:
-- How does recorded sales value vary by month?
--
-- Reporting purpose:
-- Supports monthly sales monitoring and comparison.
--
-- Output:
-- One row per year and month, ordered chronologically.
-- =========================================================

SELECT
    order_year,
    order_month,
    SUM(total_sales) AS monthly_recorded_sales_value
FROM sales_clean
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;


-- =========================================================
-- QUERY 03: TOP FIVE PRODUCTS BY RECORDED SALES VALUE
--
-- Business question:
-- Which products have the highest recorded sales value?
--
-- Reporting purpose:
-- Summarises product-level recorded sales value and
-- units sold in the available dataset.
--
-- Output:
-- Up to five products, ranked by recorded sales value.
--
-- Tie-breaking:
-- Product name is used for consistent ordering when
-- recorded sales values are equal.
-- =========================================================

SELECT
    product_name,
    SUM(quantity) AS total_units_sold,
    SUM(total_sales) AS total_recorded_sales_value
FROM sales_clean
GROUP BY
    product_name
ORDER BY
    total_recorded_sales_value DESC,
    product_name ASC
LIMIT 5;


-- =========================================================
-- QUERY 04: RECORDED SALES VALUE BY CATEGORY
--
-- Business question:
-- How is recorded sales value distributed across
-- product categories?
--
-- Reporting purpose:
-- Supports category-level sales reporting
-- and comparison.
--
-- Output:
-- One row per category, ordered by recorded sales value.
-- =========================================================

SELECT
    category,
    SUM(total_sales) AS category_recorded_sales_value
FROM sales_clean
GROUP BY
    category
ORDER BY
    category_recorded_sales_value DESC,
    category ASC;


-- =========================================================
-- QUERY 05: TOP FIVE CUSTOMERS BY RECORDED SALES VALUE
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
--
-- Limitation:
-- This measures recorded sales value associated with
-- customers. It does not establish profitability,
-- customer lifetime value, or future customer behaviour.
-- =========================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(sc.total_sales) AS total_recorded_sales_value
FROM sales_clean AS sc
INNER JOIN customers AS c
    ON sc.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_recorded_sales_value DESC,
    c.customer_id ASC
LIMIT 5;


-- =========================================================
-- QUERY 06: CUSTOMER JOIN ROW-COUNT VALIDATION
--
-- Business question:
-- Does joining sales records to customer details change
-- the number of sales rows?
--
-- Reporting purpose:
-- Checks whether the customer join changes the row count.
--
-- Validation approach:
-- Compare the source sales-row count with the joined
-- sales-row count.
--
-- Expected result:
-- Equal counts when every sales record matches exactly
-- one customer record.
--
-- Important:
-- A matching row count does not prove that every customer
-- relationship is correct. It is one validation check.
-- =========================================================

WITH source_sales AS (
    SELECT
        COUNT(*) AS source_row_count
    FROM sales_clean
),
joined_sales AS (
    SELECT
        COUNT(*) AS joined_row_count
    FROM sales_clean AS sc
    INNER JOIN customers AS c
        ON sc.customer_id = c.customer_id
)
SELECT
    source_sales.source_row_count,
    joined_sales.joined_row_count,
    joined_sales.joined_row_count
        - source_sales.source_row_count AS row_count_difference,
    CASE
        WHEN source_sales.source_row_count
             = joined_sales.joined_row_count
        THEN 'PASS'
        ELSE 'REVIEW'
    END AS validation_status
FROM source_sales
CROSS JOIN joined_sales;

