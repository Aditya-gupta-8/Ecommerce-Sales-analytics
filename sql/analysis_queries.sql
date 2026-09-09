-- E-Commerce Sales Analytics
-- SQL dialect: PostgreSQL / MySQL 8+ compatible with minor date-function changes

-- 1. Total sales, orders, customers and profit
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2) AS profit_margin_pct
FROM ecommerce_orders
WHERE order_status <> 'Cancelled';

-- 2. Monthly sales and profit
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit,
    COUNT(DISTINCT order_id) AS orders
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY 1
ORDER BY 1;

-- 3. Category performance
SELECT
    category,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit,
    SUM(quantity) AS units_sold,
    ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2) AS margin_pct
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY category
ORDER BY sales DESC;

-- 4. Top 10 products by revenue
SELECT
    product_id, product_name, category,
    ROUND(SUM(sales),2) AS revenue,
    SUM(quantity) AS units_sold
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY product_id, product_name, category
ORDER BY revenue DESC
LIMIT 10;

-- 5. Top customers by lifetime value
SELECT
    customer_id, customer_name, region,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales),2) AS lifetime_value,
    ROUND(SUM(profit),2) AS lifetime_profit
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY customer_id, customer_name, region
ORDER BY lifetime_value DESC
LIMIT 20;

-- 6. Region performance
SELECT
    region,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales),2) AS sales,
    ROUND(SUM(profit),2) AS profit
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY region
ORDER BY sales DESC;

-- 7. Payment method mix
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales),2) AS sales
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY payment_method
ORDER BY sales DESC;

-- 8. Return/cancellation rate
SELECT
    ROUND(100.0 * SUM(CASE WHEN order_status='Returned' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*),0),2) AS return_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*),0),2) AS cancellation_rate_pct
FROM ecommerce_orders;

-- 9. Repeat customer rate
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM ecommerce_orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    ROUND(100.0 * SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END)
        / COUNT(*),2) AS repeat_customer_rate_pct
FROM customer_orders;

-- 10. Average order value by month
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales)/NULLIF(COUNT(DISTINCT order_id),0),2) AS avg_order_value
FROM ecommerce_orders
WHERE order_status <> 'Cancelled'
GROUP BY 1
ORDER BY 1;
