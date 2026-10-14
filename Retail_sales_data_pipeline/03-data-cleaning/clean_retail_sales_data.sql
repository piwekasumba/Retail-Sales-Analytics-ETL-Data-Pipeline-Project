
-- ==========================================================
-- RETAIL SALES ANALYTICS ETL DATA PIPELINE
-- Data Quality Checks and Cleaning
-- PostgreSQL
--
-- Purpose:
-- Identify potential data-quality issues before using
-- retail data for analysis and KPI reporting.
--
-- Approach:
-- 1. Identify records that need review.
-- 2. Check the scope of each issue before making changes.
-- 3. Apply corrections only when the intended treatment
--    is supported by the data or documented business rules.
-- 4. Recheck the data after any approved changes.
--
-- Note:
-- These queries are intended for a simulated portfolio
-- dataset. Review the results before running any DELETE
-- or UPDATE statement.
-- ==========================================================


-- ==========================================================
-- 1. CUSTOMER DATA QUALITY
--
-- Business question:
-- Are customer records missing essential information?
--
-- Reporting relevance:
-- Missing names or email addresses may limit customer
-- identification, contact-related reporting, and analysis.
--
-- First identify the affected records.
-- ==========================================================

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


-- Review before making changes:
-- Do not automatically delete these customers.
-- Confirm whether the missing fields are required and
-- whether the records are needed for sales reporting.


-- ==========================================================
-- 2. PRODUCT PRICE VALIDATION
--
-- Business question:
-- Are any products recorded with zero or negative prices?
--
-- Reporting relevance:
-- Invalid prices can affect sales calculations and
-- product-level reporting.
--
-- First identify the affected records.
-- ==========================================================

SELECT *
FROM products
WHERE price IS NULL
   OR price <= 0;


-- Count affected product records.
SELECT COUNT(*) AS products_with_invalid_prices
FROM products
WHERE price IS NULL
   OR price <= 0;


-- Review before making changes:
-- Confirm the expected pricing rules before correcting
-- or excluding any product records.


-- ==========================================================
-- 3. ORDER ITEM QUANTITY VALIDATION
--
-- Business question:
-- Are any order items missing a quantity or recording
-- a zero or negative quantity?
--
-- Reporting relevance:
-- Invalid quantities can distort item-level sales
-- calculations and related KPIs.
--
-- First identify the affected records.
-- ==========================================================

SELECT *
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;


-- Count affected order items.
SELECT COUNT(*) AS order_items_with_invalid_quantities
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0;


-- Review before making changes:
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
-- Incorrect order totals can affect revenue summaries
-- and sales trend analysis.
--
-- First identify the affected records.
-- ==========================================================

SELECT *
FROM orders
WHERE total_amount IS NULL
   OR total_amount < 0;


-- Count affected orders.
SELECT COUNT(*) AS orders_with_missing_or_negative_totals
FROM orders
WHERE total_amount IS NULL
   OR total_amount < 0;


-- Important:
-- A zero total is not automatically invalid. It may be
-- valid under a documented business rule, for example
-- for a fully discounted or cancelled order.
--
-- Before correcting an order total, compare it with
-- the associated order items and the project's
-- documented calculation rules.


-- ==========================================================
-- 5. INVENTORY VALIDATION
--
-- Business question:
-- Are any inventory records missing stock quantities
-- or showing negative stock?
--
-- Reporting relevance:
-- Invalid inventory values can affect stock reporting
-- and may indicate data-entry or processing issues.
--
-- First identify the affected records.
-- ==========================================================

SELECT *
FROM inventory
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;


-- Count affected inventory records.
SELECT COUNT(*) AS inventory_records_needing_review
FROM inventory
WHERE stock_quantity IS NULL
   OR stock_quantity < 0;


-- Review before making changes:
-- Do not automatically replace negative stock with zero.
-- Check the source record and the intended inventory rules.
-- Record any approved correction and its reason.


-- ==========================================================
-- 6. DATA QUALITY SUMMARY
--
-- Business question:
-- How many records in each area need further review?
--
-- Purpose:
-- Summarise the issues identified by the checks above.
-- These counts measure records requiring review; they do
-- not, by themselves, prove the cause of each issue.
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
-- 7. AFTER-CHECKS
--
-- Run the relevant validation query again after an
-- approved correction to check whether the issue remains.
--
-- Do not report an issue as resolved until the updated
-- query results have been reviewed.
-- ==========================================================

-- End of data quality checks.


