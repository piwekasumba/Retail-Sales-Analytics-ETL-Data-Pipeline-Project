
-- ==========================================================
-- RETAIL SALES ANALYTICS ETL DATA PIPELINE
-- PostgreSQL Database Schema
--
-- Purpose:
-- Create a relational database structure for a simulated
-- retail dataset used to practise SQL-based reporting,
-- data preparation and data-quality checks.
--
-- Project focus:
-- - Sales and revenue reporting
-- - Customer and product analysis
-- - Order-level and item-level reconciliation
-- - Inventory monitoring
-- - Relational data integrity
--
-- This is a self-directed learning project using simulated
-- data. It does not represent production work experience.
-- ==========================================================


-- ==========================================================
-- 1. CUSTOMERS
-- Stores customer details used in sales reporting.
-- ==========================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100) NOT NULL DEFAULT 'South Africa'
);


-- ==========================================================
-- 2. PRODUCTS
-- Stores product descriptions, categories and unit prices.
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
-- total_amount is the recorded order total. It can be
-- compared with totals calculated from order_items as a
-- reconciliation check.
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
-- price is the unit price recorded for this order item.
-- It is stored separately from products.price so reporting
-- can use the price recorded for the transaction.
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
-- This table represents current stock, not a full history
-- of stock movements.
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
-- ==========================================================

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_order_date
    ON orders(order_date);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
    ON order_items(order_id);

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
-- Note:
-- The schema defines table structures and constraints.
-- Data loading, ETL steps, validation queries and reporting
-- must be performed and checked separately.
-- ==========================================================



