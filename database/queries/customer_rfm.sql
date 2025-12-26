CREATE OR REPLACE VIEW customer_rfm AS
SELECT
    u.id AS user_id,
    MAX(o.order_date) AS last_order_date,
    COUNT(o.id) AS frequency,
    SUM(o.total_amount) AS monetary
FROM users u
LEFT JOIN orders o
    ON u.id = o.user_id
    AND o.status = 'completed'
GROUP BY u.id;