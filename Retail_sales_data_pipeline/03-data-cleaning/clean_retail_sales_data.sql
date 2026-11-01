
-- ==========================================================
-- RETAIL SALES ANALYTICS ETL DATA PIPELINE
-- Data Quality Checks and Cleaning
-- PostgreSQL
--
-- Purpose:
-- Identify potential data-quality issues before using
-- retail data for analysis and KPI reporting.
--
-- Validation workflow:
-- 1. Identify records requiring review.
-- 2. Count affected records.
-- 3. Investigate potential causes.
-- 4. Apply corrections only when supported by evidence
--    or documented business rules.
-- 5. Re-run the relevant checks after approved changes.
--
-- Important:
-- This script is designed for a simulated portfolio dataset.
-- It identifies potential issues; it does not automatically
-- clean, delete, or update records.
--
-- Review the results before making any data changes.
-- ==========================================================


-- ==========================================================
-- 1. CUSTOMER DATA QUALITY
--
-- Business question:
-- Are customer records missing essential information?
--
-- Reporting relevance:
-- Missing customer details may limit customer-level
-- identification and analysis.
-- ==========================================================

-- Identify customer records with missing details.
SELECT *
FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;


-- Count affected customer records.
SELECT COUNT(*) AS customers_with_missing_details
FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;


-- Review:
-- Missing details do not automatically justify deletion.
-- Confirm whether the fields are required and whether
-- the customer records remain relevant to sales reporting.


-- ==========================================================
-- 2. PRODUCT PRICE VALIDATION
--
-- Business question:
-- Are product prices missing or recorded as zero
-- or negative values?
--
-- Reporting relevance:
-- Invalid prices may affect sales calculations,
-- revenue reporting, and product-level analysis.
-- ==========================================================

-- Identify products requiring price review.
SELECT *
FROM products
WHERE price IS NULL
   OR price <= 0;


-- Count affected product records.
SELECT COUNT(*) AS products_with_invalid_prices
FROM products
WHERE price IS NULL
   OR price <= 0;


-- Review:
-- Confirm the intended pricing rules before correcting
-- or excluding any product records.
-- A zero price may be valid under a documented rule.


-- ==========================================================
-- 3. ORDER ITEM QUANTITY VALIDATION
--
-- Business question:
-- Are order items missing quantities or recording
-- zero or negative quantities?
--
-- Reporting relevance:
-- Invalid quantities may distort item-level calculations
-- and sales-related KPIs.
-- ==========================================================

-- Identify order items requiring quantity review.
SELECT *
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;


-- Count affected order items.
SELECT COUNT(*) AS order_items_with_invalid_quantities
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;


-- Review:
-- Do not automatically delete affected order items.
-- Check whether returns, cancellations, or other
-- documented business rules explain the values.


-- ==========================================================
-- 4. ORDER TOTAL VALIDATION
--
-- Business question:
-- Are order totals missing or recorded as negative?
--
-- Reporting relevance:
-- Incorrect order totals may affect revenue summaries
-- and sales trend analysis.
-- ==========================================================

-- Identify orders requiring total review.
SELECT *
FROM orders
WHERE total_amount IS NULL
   OR total_amount < 0;


-- Count affected orders.
SELECT COUNT(*) AS orders_with_missing_or_negative_totals
FROM orders
WHERE total_amount IS NULL
   OR total_amount < 0;


-- Review:
-- A zero total is not automatically invalid.
-- It may be valid under documented business rules.
--
-- Compare order totals with their associated order items
-- before approving any correction.


-- ==========================================================
-- 5. ORDER TOTAL RECONCILIATION
--
-- Business question:
-- Do recorded order totals agree with the calculated
-- value of their associated order items?
--
-- Reporting relevance:
-- Differences may affect revenue reporting and indicate
-- potential inconsistencies between orders and order items.
--
-- Assumption:
-- Order item value is calculated as quantity * product price.
-- This comparison does not account for discounts, tax,
-- shipping, or other adjustments unless those rules are
-- incorporated into the calculation.
-- ==========================================================

WITH order_item_totals AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * p.price) AS calculated_item_total,
        COUNT(*) AS order_item_count
    FROM order_items AS oi
    INNER JOIN products AS p
        ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)

SELECT
    o.order_id,
    o.total_amount AS recorded_order_total,
    oit.calculated_item_total,
    oit.order_item_count,
    o.total_amount - oit.calculated_item_total
        AS reconciliation_difference
FROM orders AS o
INNER JOIN order_item_totals AS oit
    ON o.order_id = oit.order_id
WHERE o.total_amount IS NULL
   OR ABS(
       o.total_amount - oit.calculated_item_total
   ) > 0.01
ORDER BY o.order_id;


-- Review:
-- A difference does not automatically prove that an
-- order total is incorrect.
--
-- Investigate documented discounts, tax, shipping,
-- rounding, and other applicable business rules.
--
-- Orders without associated order items are not included
-- in this reconciliation result and should be reviewed
-- separately if they are relevant to the reporting scope.


-- ==========================================================
-- 6. INVENTORY VALIDATION
--
-- Business question:
-- Are inventory records missing stock quantities
-- or showing negative stock?
--
-- Reporting relevance:
-- Invalid inventory values may affect stock reporting
-- and indicate potential data-entry or processing issues.
-- ==========================================================

-- Identify inventory records requiring review.
SELECT *
FROM inventory
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;


-- Count affected inventory records.
SELECT COUNT(*) AS inventory_records_needing_review
FROM inventory
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;


-- Review:
-- Do not automatically replace negative stock with zero.
-- Investigate the source record and intended inventory rules.
-- Record the reason for any approved correction.


-- ==========================================================
-- 7. DATA QUALITY SUMMARY
--
-- Business question:
-- How many records require further review in each area?
--
-- Purpose:
-- Provide a consolidated view of the validation results.
--
-- These counts measure records requiring review.
-- They do not establish the cause of an issue.
-- ==========================================================

SELECT
    'Customers with missing details' AS quality_check,
    COUNT(*) AS affected_records
FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL

UNION ALL

SELECT
    'Products with invalid prices',
    COUNT(*)
FROM products
WHERE price IS NULL
   OR price <= 0

UNION ALL

SELECT
    'Order items with invalid quantities',
    COUNT(*)
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0

UNION ALL

SELECT
    'Orders with missing or negative totals',
    COUNT(*)
FROM orders
WHERE total_amount IS NULL
   OR total_amount < 0

UNION ALL

SELECT
    'Inventory records needing review',
    COUNT(*)
FROM inventory
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;


-- ==========================================================
-- 8. AFTER-CHECKS
--
-- Purpose:
-- Re-run the relevant validation queries after an
-- approved correction.
--
-- Review the results before reporting an issue as resolved.
-- ==========================================================

-- End of data quality checks.


