-- =========================================================
-- ANALYTICAL QUERIES (POSTGRESQL)
-- Retail Sales Analytics ETL Data Pipeline
--
-- Project context:
-- Self-directed SQL reporting work using simulated
-- retail data prepared within the project.
--
-- Purpose:
-- Explore reporting questions using the prepared sales
-- dataset and related customer information.
--
-- Reporting areas:
-- 1. Overall recorded sales value
-- 2. Monthly recorded sales value
-- 3. Product performance
-- 4. Category performance
-- 5. Customer sales analysis
-- 6. Customer join validation
--
-- Reporting definitions:
-- - Recorded sales value is calculated using SUM(total_sales).
-- - Monthly reporting groups records by order_year
--   and order_month.
-- - Customer sales value represents recorded sales
--   associated with each customer in the dataset.
--
-- Limitations:
-- These queries produce descriptive reporting outputs.
-- They do not establish business causes, profitability,
-- customer lifetime value or future performance.
-- =========================================================


-- =========================================================
-- QUERY 01: OVERALL RECORDED SALES VALUE
--
-- Business question:
-- What is the total recorded sales value?
--
-- Reporting purpose:
-- Summarises the recorded sales value across the
-- available prepared dataset.
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
-- Product name provides consistent ordering when
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
-- Demonstrates joining prepared sales records to
-- customer information and aggregating at customer level.
--
-- Output:
-- Up to five customers, ranked by recorded sales value.
--
-- Limitation:
-- This measures recorded sales value associated with
-- customers included in the join.
-- It does not establish profitability, customer lifetime
-- value or future customer behaviour.
--
-- Note:
-- INNER JOIN excludes sales records without a matching
-- customer record. Query 06 provides a separate check
-- of the customer join.
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
-- QUERY 06: CUSTOMER JOIN VALIDATION
--
-- Business question:
-- Does joining prepared sales records to customer
-- information preserve the sales row count?
--
-- Reporting purpose:
-- Reviews whether the customer join introduces
-- missing matches or additional joined rows.
--
-- Validation checks:
-- 1. Compare source and joined sales row counts.
-- 2. Count sales records without a matching customer.
-- 3. Identify duplicated non-null customer IDs.
--
-- Expected conditions for PASS:
-- - No unmatched sales records.
-- - No duplicated non-null customer IDs.
-- - Joined and source sales row counts are equal.
--
-- Important limitation:
-- These checks provide evidence about row preservation
-- and customer-key uniqueness. They do not prove that
-- every customer relationship or attribute is correct.
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
),

unmatched_sales AS (
    SELECT
        COUNT(*) AS unmatched_sales_row_count
    FROM sales_clean AS sc
    WHERE NOT EXISTS (
        SELECT 1
        FROM customers AS c
        WHERE c.customer_id = sc.customer_id
    )
),

duplicate_customer_ids AS (
    SELECT
        COUNT(*) AS duplicate_customer_id_count
    FROM (
        SELECT
            customer_id
        FROM customers
        WHERE customer_id IS NOT NULL
        GROUP BY customer_id
        HAVING COUNT(*) > 1
    ) AS duplicates
)

SELECT
    source_sales.source_row_count,
    joined_sales.joined_row_count,
    joined_sales.joined_row_count
        - source_sales.source_row_count AS row_count_difference,
    unmatched_sales.unmatched_sales_row_count,
    duplicate_customer_ids.duplicate_customer_id_count,
    CASE
        WHEN unmatched_sales.unmatched_sales_row_count = 0
         AND duplicate_customer_ids.duplicate_customer_id_count = 0
         AND source_sales.source_row_count = joined_sales.joined_row_count
        THEN 'PASS'
        ELSE 'REVIEW'
    END AS validation_status
FROM source_sales
CROSS JOIN joined_sales
CROSS JOIN unmatched_sales
CROSS JOIN duplicate_customer_ids;

