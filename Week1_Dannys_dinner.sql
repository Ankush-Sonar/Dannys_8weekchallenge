
-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    s.customer_id, SUM(price)
FROM
    sales s
        LEFT JOIN
    menu m ON s.product_id = m.product_id
        LEFT JOIN
    members mb ON s.customer_id = mb.customer_id
GROUP BY s.customer_id;

