
-- ============================================================
-- RETAIL SALES ANALYTICS ETL DATA PIPELINE
-- DATABASE SCHEMA
-- PostgreSQL
--
-- Purpose:
-- Define the relational database structure used to organise
-- simulated retail data for SQL-based preparation, analysis
-- and reporting.
--
-- Reporting and analysis areas:
--   1. Sales and revenue analysis
--   2. Customer and product analysis
--   3. Order-level and item-level reconciliation
--   4. Inventory monitoring
--   5. Relational integrity and data quality
--
-- Project boundary:
-- This is a self-directed learning project using simulated
-- data. It does not represent production work experience.
--
-- Execution:
-- Creates tables and indexes when they do not already exist.
-- Does not migrate existing structures or load data.
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- Customer details used in retail reporting.
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100) NOT NULL DEFAULT 'South Africa'
);


-- ============================================================
-- 2. PRODUCTS
-- Product descriptions, categories and reference prices.
-- ============================================================

CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(12,2) NOT NULL
        CHECK (price >= 0)
);


-- ============================================================
-- 3. ORDERS
-- Customer orders and their recorded order totals.
--
-- total_amount stores the recorded order value.
-- It is not automatically calculated from order_items.
--
-- Reconciliation:
-- Compare total_amount against the sum of quantity * price
-- for the corresponding order items.
-- ============================================================

CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL
        REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL
        CHECK (total_amount >= 0)
);


-- ============================================================
-- 4. ORDER ITEMS
-- Individual product lines belonging to customer orders.
--
-- price stores the transaction-level unit price rather
-- than relying on the current products.price value.
--
-- Each row represents one product line within an order.
-- ============================================================

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL
        REFERENCES orders(order_id),
    product_id INT NOT NULL
        REFERENCES products(product_id),
    quantity INT NOT NULL
        CHECK (quantity > 0),
    price NUMERIC(12,2) NOT NULL
        CHECK (price >= 0)
);


-- ============================================================
-- 5. INVENTORY
-- Recorded stock quantity for each product.
--
-- Represents a stock snapshot, not inventory movement
-- history. One inventory record is permitted per product.
-- ============================================================

CREATE TABLE IF NOT EXISTS inventory (
    product_id INT PRIMARY KEY
        REFERENCES products(product_id),
    stock_quantity INT NOT NULL DEFAULT 0
        CHECK (stock_quantity >= 0),
    last_restock_date DATE
);


-- ============================================================
-- 6. INDEXES
-- Support common foreign-key lookups and reporting filters.
--
-- Primary keys and UNIQUE constraints create their own
-- indexes. These additional indexes support other lookups.
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_order_date
    ON orders(order_date);

CREATE INDEX IF NOT EXISTS idx_order_items_order_product
    ON order_items(order_id, product_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON order_items(product_id);


-- ============================================================
-- 7. RELATIONSHIPS AND REPORTING CONSIDERATIONS
--
-- customers (1) ------< orders
-- orders (1) ---------< order_items
-- products (1) -------< order_items
-- products (1) ------- inventory
--
-- These relationships support practice in:
--   - Sales and revenue reporting
--   - Customer purchase analysis
--   - Product and category analysis
--   - Order-total reconciliation
--   - Inventory monitoring
--
-- Data-quality considerations:
--   - Check for orphaned or unmatched records.
--   - Compare recorded and calculated order totals.
--   - Validate row counts before and after joins.
--   - Confirm reporting grain before aggregation.
--   - Review missing or inconsistent business values.
--
-- Implementation boundary:
-- This script defines database structures, relationships,
-- constraints and indexes.
--
-- Data loading, ETL transformations, validation queries
-- and reporting outputs are handled separately.
-- ============================================================



