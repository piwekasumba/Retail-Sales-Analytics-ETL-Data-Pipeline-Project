
-- ==========================================================
-- RETAIL SALES ANALYTICS ETL DATA PIPELINE
-- PostgreSQL Database Schema
--
-- Purpose:
-- Define a relational database structure for a simulated
-- retail dataset used to practise SQL-based reporting,
-- data preparation and data-quality checks.
--
-- Reporting areas:
-- - Sales and revenue reporting
-- - Customer and product analysis
-- - Order-level and item-level reconciliation
-- - Inventory monitoring
-- - Relational data integrity
--
-- Data and experience boundary:
-- This is a self-directed learning project using simulated
-- data. It does not represent production work experience.
--
-- Execution note:
-- This script creates tables and indexes if they do not
-- already exist. It does not migrate existing table
-- structures or load data.
-- ==========================================================


-- ==========================================================
-- 1. CUSTOMERS
-- Stores customer details used in sales reporting.
-- ==========================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100) NOT NULL DEFAULT 'South Africa'
);


-- ==========================================================
-- 2. PRODUCTS
-- Stores product descriptions, categories and current
-- reference prices.
-- ==========================================================

CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(12,2) NOT NULL
        CHECK (price >= 0)
);


-- ==========================================================
-- 3. ORDERS
-- Stores order dates and recorded order totals.
--
-- total_amount represents the recorded order total.
-- It is not automatically calculated from order_items.
--
-- Reconciliation:
-- Compare total_amount with the sum of quantity * price
-- from order_items for the same order.
-- ==========================================================

CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL
        REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL
        CHECK (total_amount >= 0)
);


-- ==========================================================
-- 4. ORDER ITEMS
-- Stores the products and quantities included in each order.
--
-- price is the unit price recorded for the transaction.
-- It is stored separately from products.price so historical
-- reporting can use the price recorded for the order item.
--
-- Each row represents one product line within an order.
-- ==========================================================

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


-- ==========================================================
-- 5. INVENTORY
-- Stores the recorded stock quantity for each product.
--
-- This table represents a stock snapshot, not a complete
-- history of inventory movements.
--
-- One inventory record is permitted per product.
-- ==========================================================

CREATE TABLE IF NOT EXISTS inventory (
    product_id INT PRIMARY KEY
        REFERENCES products(product_id),
    stock_quantity INT NOT NULL DEFAULT 0
        CHECK (stock_quantity >= 0),
    last_restock_date DATE
);


-- ==========================================================
-- 6. INDEXES
-- Support common joins and date-based reporting queries.
--
-- Primary keys and UNIQUE constraints create their own
-- indexes. The following indexes support foreign-key
-- lookups and reporting filters.
-- ==========================================================

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_order_date
    ON orders(order_date);

-- Composite index supports order-level item retrieval
-- and product lookups within an order.
CREATE INDEX IF NOT EXISTS idx_order_items_order_product
    ON order_items(order_id, product_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON order_items(product_id);


-- ==========================================================
-- 7. RELATIONSHIPS AND REPORTING USE
--
-- customers (1) ------< orders
-- orders (1) ---------< order_items
-- products (1) -------< order_items
-- products (1) ------- inventory
--
-- These relationships support practice in:
-- - Sales and revenue reporting
-- - Customer purchase analysis
-- - Product and category performance
-- - Order-total reconciliation
-- - Inventory monitoring
-- - Data validation and relational integrity
--
-- Data-quality considerations:
-- - Check for orphaned or unmatched records.
-- - Compare recorded order totals with calculated totals.
-- - Validate row counts before and after joins.
-- - Confirm the reporting grain before aggregating.
-- - Review missing or inconsistent business values.
--
-- Note:
-- The schema defines table structures, relationships,
-- constraints and indexes.
--
-- Data loading, ETL processing, validation queries and
-- reporting outputs must be performed and reviewed
-- separately.
-- ==========================================================



