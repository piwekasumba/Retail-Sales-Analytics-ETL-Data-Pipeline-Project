-- ==========================================================
-- DATA TRANSFORMATION LAYER
-- Retail Sales Analytics ETL Data Pipeline
-- PostgreSQL
-- ==========================================================
--
-- Purpose:
-- Transform source order data into reporting-ready datasets.
--
-- Reporting outputs:
-- 1. sales_reporting
-- 2. monthly_sales_summary
-- 3. product_sales_summary
--
-- Business use:
-- Support sales reporting, KPI calculations and analysis of
-- monthly sales trends and product performance.
--
-- Data scope:
-- sales_reporting contains one row per matched order item.
--
-- Important:
-- - Source tables must exist and contain the required columns.
-- - oi.price is assumed to represent the price per unit.
-- - INNER JOINs exclude records without matching related rows.
-- - These outputs are recreated when this script is rerun.
-- - This script creates reporting tables; it does not load
--   or validate the original source data.
-- ==========================================================


-- ==========================================================
-- STEP 1: REBUILD REPORTING OUTPUTS
--
-- Drop dependent summary tables before their source table.
-- These are generated outputs, not the original source data.
-- ==========================================================

DROP TABLE IF EXISTS product_sales_summary;
DROP TABLE IF EXISTS monthly_sales_summary;
DROP TABLE IF EXISTS sales_reporting;


-- ==========================================================
-- STEP 2: SALES REPORTING DATASET
--
-- Business purpose:
-- Combine order, order-item and product details into a
-- reporting dataset at order-item level.
--
-- Reporting use:
-- Calculate sales totals and support product and time-based
-- analysis.
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
-- STEP 3: MONTHLY SALES SUMMARY
--
-- Business purpose:
-- Summarise sales by year and month.
--
-- Reporting measures:
-- - Number of distinct orders represented
-- - Total units sold
-- - Total recorded sales value
--
-- Note:
-- These figures reflect the records included in
-- sales_reporting, not necessarily every source record.
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
-- STEP 4: PRODUCT SALES SUMMARY
--
-- Business purpose:
-- Compare products using units sold and recorded sales value.
--
-- Reporting measures:
-- - Total units sold
-- - Total recorded revenue
-- - Revenue rank within the reporting dataset
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
-- STEP 5: REVIEW THE REPORTING OUTPUTS
--
-- Run these queries after the transformation succeeds.
-- ==========================================================

-- Review the reporting dataset.
SELECT *
FROM sales_reporting
LIMIT 20;


-- Review monthly sales performance.
SELECT *
FROM monthly_sales_summary
ORDER BY order_year, order_month;


-- Review product performance.
SELECT *
FROM product_sales_summary
ORDER BY revenue_rank, product_name;


