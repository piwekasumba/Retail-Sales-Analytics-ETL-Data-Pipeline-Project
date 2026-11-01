
-- ==========================================================
-- DATA TRANSFORMATION LAYER
-- Retail Sales Analytics ETL Data Pipeline
-- PostgreSQL
-- ==========================================================
--
-- PURPOSE
-- Transform source order data into reporting-ready datasets.
--
-- REPORTING OUTPUTS
-- 1. sales_reporting
-- 2. monthly_sales_summary
-- 3. product_sales_summary
--
-- BUSINESS USE
-- Support sales reporting, KPI calculations, monthly sales
-- analysis and product performance comparisons.
--
-- REPORTING GRAIN
-- sales_reporting: one row per matched order item.
-- monthly_sales_summary: one row per year and month.
-- product_sales_summary: one row per product and category.
--
-- TRANSFORMATION ASSUMPTIONS
-- - Source tables contain the required columns.
-- - oi.price represents the price per unit.
-- - quantity multiplied by price represents recorded sales.
-- - INNER JOINs exclude records without matching related rows.
-- - Revenue represents recorded sales, not profit.
-- - No returns, discounts, taxes or shipping adjustments
--   are applied in this transformation.
--
-- EXECUTION NOTES
-- - Run the complete script in the intended database.
-- - Review the validation queries after transformation.
-- - Generated reporting tables are rebuilt on each execution.
-- - Original source tables are not modified.
-- - Validation queries identify issues but do not correct them.
--
-- ==========================================================


-- ==========================================================
-- STEP 1: REBUILD REPORTING OUTPUTS
--
-- Remove dependent summary tables before their source table.
-- Only generated reporting outputs are dropped.
-- ==========================================================

DROP TABLE IF EXISTS product_sales_summary;
DROP TABLE IF EXISTS monthly_sales_summary;
DROP TABLE IF EXISTS sales_reporting;


-- ==========================================================
-- STEP 2: CREATE SALES REPORTING DATASET
--
-- Business purpose:
-- Combine order, order-item and product details.
--
-- Reporting grain:
-- One row per matched order item.
--
-- Reporting measures:
-- - Quantity
-- - Recorded sales value
-- ==========================================================

CREATE TABLE sales_reporting AS
SELECT
    o.order_id,
    o.customer_id,
    oi.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.price,

    (oi.quantity * oi.price) AS total_sales,

    o.order_date,

    EXTRACT(YEAR FROM o.order_date)::INT AS order_year,
    EXTRACT(MONTH FROM o.order_date)::INT AS order_month

FROM orders AS o

INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN products AS p
    ON oi.product_id = p.product_id;


-- ==========================================================
-- STEP 3: CREATE MONTHLY SALES SUMMARY
--
-- Business purpose:
-- Summarise recorded sales by calendar year and month.
--
-- Reporting measures:
-- - Distinct orders represented
-- - Total units sold
-- - Recorded sales value
--
-- Note:
-- Results reflect matched order items included in
-- sales_reporting.
-- ==========================================================

CREATE TABLE monthly_sales_summary AS
SELECT
    order_year,
    order_month,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity) AS total_units_sold,

    SUM(total_sales) AS monthly_revenue

FROM sales_reporting

GROUP BY
    order_year,
    order_month;


-- ==========================================================
-- STEP 4: CREATE PRODUCT SALES SUMMARY
--
-- Business purpose:
-- Compare product performance using recorded sales value
-- and total units sold.
--
-- Reporting measures:
-- - Total units sold
-- - Total recorded revenue
-- - Revenue rank
--
-- Note:
-- Products with equal revenue receive the same rank.
-- ==========================================================

CREATE TABLE product_sales_summary AS
SELECT
    product_id,
    product_name,
    category,

    SUM(quantity) AS total_units_sold,

    SUM(total_sales) AS total_revenue,

    RANK() OVER (
        ORDER BY SUM(total_sales) DESC
    ) AS revenue_rank

FROM sales_reporting

GROUP BY
    product_id,
    product_name,
    category;


-- ==========================================================
-- STEP 5: VALIDATE TRANSFORMATION OUTPUTS
--
-- Review row counts, reporting grain and source matching.
--
-- These checks provide review evidence.
-- They do not automatically repair data quality issues.
-- ==========================================================


-- ----------------------------------------------------------
-- CHECK 1: SOURCE AND REPORTING ROW COUNTS
--
-- Compare source order-item records with reporting records.
--
-- A difference may indicate unmatched orders or products.
-- ----------------------------------------------------------

SELECT
    'Source order items' AS dataset,
    COUNT(*) AS row_count

FROM order_items

UNION ALL

SELECT
    'Sales reporting' AS dataset,
    COUNT(*) AS row_count

FROM sales_reporting;


-- ----------------------------------------------------------
-- CHECK 2: REPORTING GRAIN
--
-- Confirm whether each order_id and product_id combination
-- appears more than once in the reporting dataset.
--
-- This check assumes an order cannot contain multiple
-- separate order-item records for the same product.
-- ----------------------------------------------------------

SELECT
    order_id,
    product_id,
    COUNT(*) AS row_count

FROM sales_reporting

GROUP BY
    order_id,
    product_id

HAVING COUNT(*) > 1

ORDER BY
    order_id,
    product_id;


-- ----------------------------------------------------------
-- CHECK 3: UNMATCHED ORDERS
--
-- Identify order-item records whose order does not exist
-- in the orders table.
-- ----------------------------------------------------------

SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.price

FROM order_items AS oi

LEFT JOIN orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_id IS NULL;


-- ----------------------------------------------------------
-- CHECK 4: UNMATCHED PRODUCTS
--
-- Identify order-item records whose product does not exist
-- in the products table.
-- ----------------------------------------------------------

SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.price

FROM order_items AS oi

LEFT JOIN products AS p
    ON oi.product_id = p.product_id

WHERE p.product_id IS NULL;


-- ----------------------------------------------------------
-- CHECK 5: INVALID OR MISSING MEASURE VALUES
--
-- Review missing or non-positive quantities and prices.
--
-- These records require business review before correction.
-- ----------------------------------------------------------

SELECT
    order_id,
    product_id,
    quantity,
    price

FROM order_items

WHERE quantity IS NULL
   OR quantity <= 0
   OR price IS NULL
   OR price < 0;


-- ----------------------------------------------------------
-- CHECK 6: SALES TOTAL RECONCILIATION
--
-- Compare reporting dataset totals with monthly summaries.
--
-- A matching result supports reconciliation of the
-- reporting dataset to its monthly aggregate.
-- ----------------------------------------------------------

SELECT
    (
        SELECT SUM(total_sales)
        FROM sales_reporting
    ) AS reporting_sales_total,

    (
        SELECT SUM(monthly_revenue)
        FROM monthly_sales_summary
    ) AS monthly_summary_sales_total;


-- ==========================================================
-- STEP 6: REVIEW REPORTING OUTPUTS
--
-- Run after successful transformation.
-- ==========================================================


-- Review individual order items.
SELECT *
FROM sales_reporting
ORDER BY order_date, order_id
LIMIT 20;


-- Review monthly sales performance.
SELECT *
FROM monthly_sales_summary
ORDER BY order_year, order_month;


-- Review product performance.
SELECT *
FROM product_sales_summary
ORDER BY revenue_rank, product_name;

