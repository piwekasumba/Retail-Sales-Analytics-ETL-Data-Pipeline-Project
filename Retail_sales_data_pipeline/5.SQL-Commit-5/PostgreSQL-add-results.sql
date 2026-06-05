-- =========================================
-- FINAL ANALYTICAL REPORTING QUERIES
-- Retail Sales Data Pipeline (PostgreSQL)
-- =========================================

-- =========================
-- TOTAL REVENUE
-- =========================

SELECT 
    SUM(total_sales) AS total_revenue
FROM sales_clean;

-- =========================
-- MONTHLY REVENUE TREND
-- =========================

SELECT 
    order_year,
    order_month,
    SUM(total_sales) AS monthly_revenue
FROM sales_clean
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- =========================
-- TOP 5 PRODUCTS BY REVENUE
-- =========================

SELECT 
    product_name,
    SUM(quantity) AS units_sold,
    SUM(total_sales) AS revenue
FROM sales_clean
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 5;

-- =========================
-- REVENUE BY CATEGORY
-- =========================

SELECT 
    category,
    SUM(total_sales) AS category_revenue
FROM sales_clean
GROUP BY category
ORDER BY category_revenue DESC;

-- =========================
-- TOP CUSTOMERS BY SPENDING
-- =========================

SELECT 
    c.first_name,
    c.last_name,
    SUM(sc.total_sales) AS total_spent
FROM sales_clean sc
JOIN customers c 
    ON sc.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- Export Top Customers to CSV
COPY (
    SELECT 
        c.first_name,
        c.last_name,
        SUM(sc.total_sales) AS total_spent
    FROM sales_clean sc
    JOIN customers c 
        ON sc.customer_id = c.customer_id
    GROUP BY c.first_name, c.last_name
    ORDER BY total_spent DESC
    LIMIT 5
)
TO 'results/top_customers.csv'
WITH CSV HEADER;
