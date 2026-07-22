-- ==========================================================
-- DATA TRANSFORMATION LAYER
-- Retail Sales Analytics ETL Data Pipeline (PostgreSQL)
-- ==========================================================
--
-- Purpose:
-- Transform cleaned transactional data into reporting-ready
-- datasets that support business analysis and KPI reporting.
--
-- Business Value:
-- The outputs created in this layer can be used for operational
-- reporting, sales monitoring and dashboard development.
-- ==========================================================


-- ==========================================================
-- REPORTING DATASET
-- Business Purpose:
-- Create a structured sales dataset by combining orders,
-- order items and product information.
--
-- Reporting Outcome:
-- Provides a clean, analysis-ready dataset for KPI reporting,
-- trend analysis and business reporting.
-- ==========================================================

CREATE TABLE IF NOT EXISTS sales_reporting AS

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

    EXTRACT(YEAR FROM o.order_date) AS order_year,
    EXTRACT(MONTH FROM o.order_date) AS order_month

FROM orders AS o

INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN products AS p
    ON oi.product_id = p.product_id;



-- ==========================================================
-- MONTHLY SALES SUMMARY
--
-- Business Purpose:
-- Summarise monthly sales performance to support management
-- reporting and trend analysis.
--
-- Reporting Outcome:
-- Produces monthly revenue totals that can be used in KPI
-- reports and dashboards.
-- ==========================================================

CREATE TABLE IF NOT EXISTS monthly_sales_summary AS

SELECT
    order_year,
    order_month,
    SUM(total_sales) AS monthly_revenue

FROM sales_reporting

GROUP BY
    order_year,
    order_month

ORDER BY
    order_year,
    order_month;



-- ==========================================================
-- PRODUCT PERFORMANCE SUMMARY
--
-- Business Purpose:
-- Measure product performance using units sold and revenue.
--
-- Reporting Outcome:
-- Produces a ranked product performance report to support
-- sales analysis and business decision-making.
-- ==========================================================

CREATE TABLE IF NOT EXISTS product_sales_summary AS

SELECT
    product_id,
    product_name,
    category,
    SUM(quantity) AS total_units_sold,
    SUM(total_sales) AS total_revenue

FROM sales_reporting

GROUP BY
    product_id,
    product_name,
    category

ORDER BY
    total_revenue DESC;

