CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255)
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    price DECIMAL(10,2),
    stock INTEGER
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    order_date TIMESTAMP,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    is_fraud BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE reviews (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    product_id INTEGER,
    order_id INTEGER,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id);
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
CREATE OR REPLACE VIEW top_products AS
SELECT
    p.id AS product_id,
    p.name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'completed'
GROUP BY p.id, p.name
ORDER BY total_revenue DESC;
CREATE TABLE IF NOT EXISTS pipeline_logs (
    id SERIAL PRIMARY KEY,
    pipeline_name VARCHAR(100),
    status VARCHAR(50),
    records_processed INTEGER,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

