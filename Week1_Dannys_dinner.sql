
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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
with new_table as
(SELECT 
    m.product_name, COUNT(*) AS times_purchased
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY m.product_name)

select * from new_table
order by times_purchased desc
limit 1;

-- 5. Which item was the most popular for each customer?
With ranked_orders AS (
    SELECT 
        s.customer_id AS customer,
        m.product_name AS product,
        COUNT(s.customer_id) AS order_count,
        RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY COUNT(s.customer_id) DESC
        ) AS rank_1 
        FROM Sales s
    LEFT JOIN Menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)

SELECT 
    customer,
    product
FROM ranked_orders
WHERE rank_1 = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH new_table AS (
    SELECT 
        s.customer_id AS customer,
        mn.product_name AS product,
        RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date
        ) AS ranking
    FROM sales s
    LEFT JOIN members m
        ON s.customer_id = m.customer_id
    LEFT JOIN menu mn
        ON s.product_id = mn.product_id
    WHERE s.order_date >= m.join_date
)

SELECT 
    customer,
    product
FROM new_table
WHERE ranking = 1;



-- 7. Which item was purchased just before the customer became a member?
WITH new_table AS (
    SELECT 
        s.customer_id AS customer,
        mn.product_name AS product,
        RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date DESC
        ) AS ranking
    FROM sales s
    LEFT JOIN members m
        ON s.customer_id = m.customer_id
    LEFT JOIN menu mn
        ON s.product_id = mn.product_id
    WHERE s.order_date < m.join_date
)

SELECT 
    customer,
    product
FROM new_table
WHERE ranking = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    s.customer_id AS customer,
    COUNT(mn.product_id) AS total_count,
    IFNULL(SUM(mn.price), 0) AS price
FROM
    sales s
        LEFT JOIN
    members m ON s.customer_id = m.customer_id
        LEFT JOIN
    menu mn ON s.product_id = mn.product_id
        AND m.customer_id IS NOT NULL
WHERE
    s.order_date < m.join_date
        OR m.join_date IS NULL
GROUP BY s.customer_id;