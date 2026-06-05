-- =========================================
-- DATA QUALITY CHECKS & CLEANING (POSTGRESQL)
-- Retail Order Management System
-- =========================================

-- =========================
-- CUSTOMER DATA QUALITY
-- =========================

-- Identify customers with missing critical information
SELECT *
FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;

-- Remove incomplete customer records (critical fields missing)
DELETE FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;

-- =========================
-- PRODUCT DATA QUALITY
-- =========================

-- Check for invalid product prices
SELECT *
FROM products
WHERE price <= 0;

-- Remove products with invalid pricing
DELETE FROM products
WHERE price <= 0;

-- =========================
-- ORDER ITEMS DATA QUALITY
-- =========================

-- Check for invalid quantities in order items
SELECT *
FROM order_items
WHERE quantity <= 0;

-- Remove invalid order item records
DELETE FROM order_items
WHERE quantity <= 0;

-- =========================
-- ORDERS DATA QUALITY
-- =========================

-- Identify orders with invalid total amounts
SELECT *
FROM orders
WHERE total_amount < 0;

-- Remove invalid order records
DELETE FROM orders
WHERE total_amount < 0;

-- =========================
-- INVENTORY DATA QUALITY
-- =========================

-- Check for negative stock values
SELECT *
FROM inventory
WHERE stock_quantity < 0;

-- Correct invalid stock values (set to zero)
UPDATE inventory
SET stock_quantity = 0
WHERE stock_quantity < 0;
