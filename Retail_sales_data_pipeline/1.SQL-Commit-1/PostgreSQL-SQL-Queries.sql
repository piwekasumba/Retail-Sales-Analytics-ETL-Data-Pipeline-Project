-- =========================================
-- RETAIL ORDER MANAGEMENT DATABASE
-- PostgreSQL RELATIONAL SCHEMA
-- =========================================

-- =========================
-- CUSTOMERS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50) DEFAULT 'South Africa'
);

-- =========================
-- PRODUCTS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price NUMERIC(10, 2) NOT NULL
);

-- =========================
-- ORDERS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL
);

-- =========================
-- ORDER ITEMS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- =========================
-- INVENTORY TABLE
-- =========================
CREATE TABLE IF NOT EXISTS inventory (
    product_id INT PRIMARY KEY REFERENCES products(product_id),
    stock_quantity INT NOT NULL DEFAULT 0,
    last_restock_date DATE
);

