-- ==========================================================
-- DATA QUALITY CHECKS & CLEANING
-- Retail Sales Analytics ETL Data Pipeline (PostgreSQL)
--
-- Purpose:
-- Validate and clean retail sales data before reporting.
-- Improving data quality helps ensure accurate KPI reporting,
-- reliable business insights, and consistent decision-making.
-- ==========================================================

-- ==========================================================
-- CUSTOMER DATA QUALITY
-- Business Question:
-- Are any customer records missing essential information?
--
-- Business Purpose:
-- Customer records with missing names or email addresses
-- reduce reporting accuracy and make customer analysis
-- unreliable.
-- ==========================================================

SELECT *
FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;

-- Remove incomplete customer records

DELETE FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;

-- ==========================================================
-- PRODUCT DATA QUALITY
-- Business Question:
-- Are there products with invalid prices?
--
-- Business Purpose:
-- Incorrect pricing affects revenue calculations,
-- sales reporting and KPI accuracy.
-- ==========================================================

SELECT *
FROM products
WHERE price <= 0;

-- Remove products with invalid prices

DELETE FROM products
WHERE price <= 0;

-- ==========================================================
-- ORDER ITEM DATA QUALITY
-- Business Question:
-- Are any order items recorded with invalid quantities?
--
-- Business Purpose:
-- Negative or zero quantities produce incorrect
-- sales totals and distort reporting results.
-- ==========================================================

SELECT *
FROM order_items
WHERE quantity <= 0;

-- Remove invalid order items

DELETE FROM order_items
WHERE quantity <= 0;

-- ==========================================================
-- ORDER DATA QUALITY
-- Business Question:
-- Are any orders recorded with invalid total amounts?
--
-- Business Purpose:
-- Incorrect order totals affect revenue reporting,
-- sales trends and financial analysis.
-- ==========================================================

SELECT *
FROM orders
WHERE total_amount < 0;

-- Remove invalid orders

DELETE FROM orders
WHERE total_amount < 0;

-- ==========================================================
-- INVENTORY DATA QUALITY
-- Business Question:
-- Are there products with negative inventory levels?
--
-- Business Purpose:
-- Negative stock values reduce reporting reliability
-- and may indicate data entry or processing errors.
-- ==========================================================

SELECT *
FROM inventory
WHERE stock_quantity < 0;

-- Correct invalid inventory values

UPDATE inventory
SET stock_quantity = 0
WHERE stock_quantity < 0;

-- ==========================================================
-- Data Quality Outcome
--
-- The cleaned dataset provides a more reliable foundation
-- for SQL analysis, KPI reporting, dashboard development,
-- and business decision-making.
-- ==========================================================
