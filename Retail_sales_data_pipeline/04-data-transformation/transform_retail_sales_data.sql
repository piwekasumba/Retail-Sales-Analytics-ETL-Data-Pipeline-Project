
-- ----------------------------------------------------------
-- CHECK 5: INVALID OR MISSING MEASURE VALUES
--
-- Review missing or invalid quantity and price values.
--
-- Quantities must be greater than zero.
-- Prices must not be negative.
-- Zero prices are permitted by this check.
--
-- These records require business review before correction.
-- ----------------------------------------------------------

SELECT
    order_id,
    product_id,
    quantity,
    price

FROM order_items

    
-- ----------------------------------------------------------
-- CHECK 6: SALES TOTAL RECONCILIATION
--
-- Compare the reporting dataset total with the total
-- recorded in the monthly sales summary.
--
-- A matching result supports consistency between the
-- detailed reporting dataset and its monthly aggregation.
--
-- Important:
-- Both datasets are derived from sales_reporting.
-- Therefore, this check does not independently establish
-- source-data completeness or identify records excluded
-- during the original transformation.
-- ----------------------------------------------------------

SELECT
    (
        SELECT SUM(total_sales)
        FROM sales_reporting
    ) AS reporting_sales_total,

    (
        SELECT SUM(monthly_revenue)
        FROM monthly_sales_summary
    ) AS monthly_summary_sales_total;

WHERE quantity IS NULL
   OR quantity <= 0
   OR price IS NULL
   OR price < 0;

