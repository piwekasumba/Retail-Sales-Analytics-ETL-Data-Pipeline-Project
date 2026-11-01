
-- ============================================================
-- RETAIL SALES REPORTING QUERIES
-- PostgreSQL
--
-- Project: RetailMart Executive Reporting SQL
-- Project type: Self-directed SQL reporting project
--
-- Data sources:
--   sales_clean
--   customers
--
-- Purpose:
-- Demonstrate SQL reporting techniques for calculating sales
-- KPIs, reviewing monthly trends, comparing products and
-- categories, and analysing customer spending.
--
-- Reporting workflow:
--   Business Question
--       -> KPI Definition
--       -> SQL Query
--       -> Validation
--       -> Reporting Output
--
-- Scope:
-- These queries use the project's existing cleaned sales data.
-- Results describe recorded dataset values, not independently
-- verified business performance or production reporting.
--
-- Before reporting:
-- Confirm the reporting period, sales-value definition,
-- order-level grain, and customer-data completeness.
-- ============================================================


-- ============================================================
-- REPORT 01: TOTAL RECORDED SALES
--
-- Business question:
-- What is the total recorded sales value?
--
-- KPI definition:
-- Sum of total_sales across the available sales records.
--
-- Reporting use:
-- Provides a high-level measure of recorded sales value.
--
-- Validation:
-- Confirm the reporting period and whether total_sales
-- represents gross sales, net sales, or another sales measure.
-- ============================================================

SELECT
    SUM(total_sales) AS total_recorded_sales
FROM sales_clean;


-- ============================================================
-- REPORT 02: MONTHLY SALES TREND
--
-- Business question:
-- How much sales value was recorded in each month?
--
-- KPI definition:
-- Sum of total_sales grouped by reporting year and month.
--
-- Reporting use:
-- Supports month-by-month monitoring and comparison.
--
-- Assumption:
-- order_year and order_month are available and correctly
-- populated in sales_clean.
--
-- Validation:
-- Confirm that the reporting period is complete before
-- comparing monthly totals.
-- ============================================================

SELECT
    order_year,
    order_month,
    SUM(total_sales) AS monthly_recorded_sales
FROM sales_clean
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;


-- ============================================================
-- REPORT 03: TOP 5 PRODUCTS BY RECORDED SALES
--
-- Business question:
-- Which products have the highest recorded sales value?
--
-- Measures:
--   units_sold:
--       Sum of quantity across product sales records.
--
--   total_recorded_sales:
--       Sum of total_sales across product sales records.
--
-- Reporting use:
-- Compares products using recorded sales value and quantity.
--
-- Validation:
-- Confirm product naming consistency and quantity definitions.
-- ============================================================

SELECT
    product_name,
    SUM(quantity) AS units_sold,
    SUM(total_sales) AS total_recorded_sales
FROM sales_clean
GROUP BY
    product_name
ORDER BY
    total_recorded_sales DESC,
    product_name
LIMIT 5;


-- ============================================================
-- REPORT 04: SALES BY PRODUCT CATEGORY
--
-- Business question:
-- How is recorded sales value distributed across categories?
--
-- KPI definition:
-- Sum of total_sales grouped by product category.
--
-- Reporting use:
-- Supports category-level sales comparison.
--
-- Validation:
-- Review missing category values and confirm category
-- classification is consistent across the reporting period.
-- ============================================================

SELECT
    category,
    SUM(total_sales) AS category_recorded_sales
FROM sales_clean
GROUP BY
    category
ORDER BY
    category_recorded_sales DESC,
    category;


-- ============================================================
-- REPORT 05: TOP 5 CUSTOMERS BY TOTAL SPENDING
--
-- Business question:
-- Which customers have the highest total recorded spending?
--
-- Reporting measures:
--   total_orders:
--       Count of distinct order-level records.
--
--   total_spent:
--       Sum of calculated order totals.
--
--   average_order_value:
--       Average calculated order total.
--
-- Method:
-- First aggregate sales lines to customer and order level.
-- Then calculate customer-level spending measures.
--
-- This prevents multiple product lines within one order
-- from being counted as separate orders.
--
-- Validation:
-- Check that order_id identifies an order within the dataset
-- and that customer_id is consistently assigned.
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
LEFT JOIN customers AS c
    ON cs.customer_id = c.customer_id
ORDER BY
    cs.total_spent DESC,
    cs.customer_id
LIMIT 5;


-- ============================================================
-- REPORT 06: EXPORT-READY CUSTOMER SPENDING RESULTS
--
-- Purpose:
-- Produces a clean result set for CSV export or further review.
--
-- Export:
-- Run this SELECT query in pgAdmin.
-- Use the result-grid export/save option to save the output
-- as CSV.
--
-- Important:
-- This query does not create or save a CSV file automatically.
--
-- Note:
-- The output contains the top five customers by total spending.
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
LEFT JOIN customers AS c
    ON cs.customer_id = c.customer_id
ORDER BY
    cs.total_spent DESC,
    cs.customer_id
LIMIT 5;


-- ============================================================
-- VALIDATION 01: SALES DATA QUALITY SUMMARY
--
-- Purpose:
-- Reviews basic completeness and value conditions in the
-- sales reporting dataset.
--
-- Checks:
--   - Total sales records
--   - Missing sales values
--   - Negative sales values
--   - Missing customer identifiers
--   - Missing order identifiers
--
-- Interpretation:
-- These are review indicators, not automatic proof of errors.
-- Negative values or missing identifiers may require
-- investigation based on the dataset's business rules.
-- ============================================================

SELECT
    COUNT(*) AS total_sales_records,
    COUNT(*) FILTER (
        WHERE total_sales IS NULL
    ) AS missing_sales_values,
    COUNT(*) FILTER (
        WHERE total_sales < 0
    ) AS negative_sales_values,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_ids,
    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ) AS missing_order_ids
FROM sales_clean;


-- ============================================================
-- VALIDATION 02: CUSTOMER MATCH REVIEW
--
-- Purpose:
-- Identifies sales records whose customer identifiers
-- do not match a record in the customers table.
--
-- Reporting use:
-- Helps review customer-data completeness before presenting
-- customer-level reporting results.
--
-- Note:
-- Multiple sales records may legitimately reference the
-- same customer. This query reports unmatched records,
-- not duplicate customers.
-- ============================================================

SELECT
    COUNT(*) AS unmatched_customer_sales_records
FROM sales_clean AS s
LEFT JOIN customers AS c
    ON s.customer_id = c.customer_id
WHERE
    s.customer_id IS NOT NULL
    AND c.customer_id IS NULL;


