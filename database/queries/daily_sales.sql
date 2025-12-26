CREATE MATERIALIZED VIEW IF NOT EXISTS daily_sales_summary AS
SELECT
    DATE(order_date) AS sales_date,
    COUNT(id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_orders
FROM orders
WHERE status = 'completed'
GROUP BY DATE(order_date);
REFRESH MATERIALIZED VIEW daily_sales_summary;