
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


-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,count(distinct order_date) as total_count FROM sales GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT 
    s.customer_id, s.order_date, m.product_name
FROM
    sales s
        LEFT JOIN
    menu m ON s.product_id = m.product_id
WHERE
    (s.customer_id , s.order_date) IN (SELECT 
            customer_id, MIN(order_date)
        FROM
            sales
        GROUP BY customer_id)
ORDER BY s.customer_id , s.order_date;
