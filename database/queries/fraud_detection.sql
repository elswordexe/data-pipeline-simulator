CREATE or REPLACE VIEW fraud_detection_summary AS
SELECT
    o.id AS order_id,
    o.user_id,
    o.order_date,
    o.total_amount,
    CASE
        WHEN o.total_amount > 1000 THEN 'high_value'
        WHEN o.total_amount BETWEEN 500 AND 1000 THEN 'medium_value'
        ELSE 'low_value'
    END AS order_value_category,
    CASE
        WHEN u.account_age_days < 30 AND o.total_amount > 500 THEN 'potential_fraud'
        WHEN u.is_flagged THEN 'high_risk_user'
        ELSE 'normal'
    END AS fraud_risk_level