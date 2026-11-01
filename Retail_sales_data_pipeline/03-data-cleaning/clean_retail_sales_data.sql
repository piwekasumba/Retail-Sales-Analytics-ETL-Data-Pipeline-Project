
-- ==========================================================
-- RETAIL SALES ANALYTICS ETL DATA PIPELINE
-- DATA QUALITY VALIDATION CHECKS
-- PostgreSQL
--
-- Purpose:
-- Identify records that may require data-quality review
-- before using retail data for analysis and reporting.
--
-- Validation workflow:
-- 1. Identify records requiring review.
-- 2. Count affected records.
-- 3. Investigate potential causes.
-- 4. Apply corrections only when supported by evidence
--    or documented business rules.
-- 5. Re-run relevant checks after approved corrections.
--
-- Important:
-- This script uses a simulated portfolio dataset.
-- It identifies potential issues but does not automatically
-- clean, delete, or update records.
--
-- Review query results before making data changes.
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

-- Identify customer records requiring review.
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
-- Confirm whether these fields are mandatory before
-- deciding whether a record requires correction.


-- ==========================================================
-- 2. PRODUCT PRICE VALIDATION
--
-- Business question:
-- Are product prices missing or recorded as negative?
--
-- Reporting relevance:
-- Invalid prices may affect sales calculations,
-- revenue reporting and product-level analysis.
-- ==========================================================

-- Identify products requiring price review.
SELECT *
FROM products
WHERE price IS NULL
   OR price < 0;

-- Count affected product records.
SELECT COUNT(*) AS products_with_invalid_prices
FROM products
WHERE price IS NULL
   OR price < 0;

-- Review:
-- The supplied schema allows zero prices.
-- A zero price is therefore not automatically invalid.
-- Confirm documented pricing rules before correction.


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

-- Identify order items requiring review.
SELECT *
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;

-- Count affected order item records.
SELECT COUNT(*) AS order_items_with_invalid_quantities
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;

-- Review:
-- Investigate whether returns, cancellations or other
-- documented business rules explain the values.
-- Do not automatically delete affected records.


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
-- Check documented business rules before correction.


-- ==========================================================
-- 5. ORDER TOTAL RECONCILIATION
--
-- Business question:
-- Do recorded order totals agree with calculated
-- order item values?
--
-- Assumption:
-- Calculated item value = quantity * product price.
--
-- This comparison does not account for discounts, tax,
-- shipping or other adjustments unless included in
-- the documented business calculation.
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
    COALESCE(oit.order_item_count, 0) AS order_item_count,
    o.total_amount - oit.calculated_item_total
        AS reconciliation_difference
FROM orders AS o
LEFT JOIN order_item_totals AS oit
    ON o.order_id = oit.order_id
WHERE oit.order_id IS NULL
   OR o.total_amount IS NULL
   OR oit.calculated_item_total IS NULL
   OR ABS(
       o.total_amount - oit.calculated_item_total
   ) > 0.01
ORDER BY o.order_id;

-- Review:
-- Differences do not automatically prove that an
-- order total is incorrect.
--
-- Investigate discounts, tax, shipping, rounding
-- and other applicable business rules.
--
-- Orders without associated order items are now
-- included in the review rather than excluded.


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
-- Investigate the source record and applicable inventory rules.


-- ==========================================================
-- 7. DATA QUALITY SUMMARY
--
-- Business question:
-- How many records require further review in each area?
--
-- Purpose:
-- Provide a consolidated view of selected validation results.
--
-- These counts identify records requiring review.
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
    'Products with missing or negative prices',
    COUNT(*)
FROM products
WHERE price IS NULL
   OR price < 0

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
    'Orders without associated order items',
    COUNT(*)
FROM orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items AS oi
    WHERE oi.order_id = o.order_id
)

UNION ALL

SELECT
    'Inventory records needing review',
    COUNT(*)
FROM inventory
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;


-- ==========================================================
-- 8. POST-CORRECTION VALIDATION
--
-- Purpose:
-- Re-run the relevant validation checks after approved
-- corrections to determine whether the identified
-- conditions remain.
--
-- Review the before-and-after results.
--
-- Do not report an issue as resolved solely because
-- a correction was attempted.
--
-- No automatic updates or deletions are performed
-- by this script.
-- ==========================================================

-- End of data quality validation checks.

