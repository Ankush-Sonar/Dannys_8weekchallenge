-- A. Pizza Metrics
-- How many pizzas were ordered?
SELECT 
    COUNT(*) AS Total_order
FROM
    customer_orders;

-- How many unique customer orders were made?
SELECT 
    COUNT(DISTINCT order_id) AS Total_order
FROM
    customer_orders;

-- How many successful orders were delivered by each runner?
SELECT 
    r.runner_id, COUNT(ro.order_id) AS count
FROM
    runner_orders ro
        RIGHT JOIN
    runners r ON ro.runner_id = r.runner_id
WHERE
    duration != 'null'
GROUP BY r.runner_id;

-- How many of each type of pizza was delivered?
SELECT 
    p.pizza_name, COUNT(p.pizza_id)
FROM
    customer_orders c
        LEFT JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
        LEFT JOIN
    runner_orders ro ON c.order_id = ro.order_id
WHERE
    ro.pickup_time != 'null'
GROUP BY p.pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    c.customer_id, p.pizza_name, COUNT(c.customer_id)
FROM
    customer_orders c
        LEFT JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
        LEFT JOIN
    runner_orders ro ON c.order_id = ro.order_id
GROUP BY c.customer_id , p.pizza_name
ORDER BY c.customer_id;

-- What was the maximum number of pizzas delivered in a single order?
SELECT 
    COUNT(ro.order_id) AS max
FROM
    customer_orders c
        LEFT JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
        LEFT JOIN
    runner_orders ro ON c.order_id = ro.order_id
WHERE
    distance != 'null'
GROUP BY ro.order_id , ro.runner_id
ORDER BY max DESC
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
with new_table as
(SELECT 
    *,
    CASE
        WHEN exclusions IS NULL OR extras IS NULL THEN 'Changes'
        ELSE 'No Changes'
    END AS changes
FROM
    customer_orders_clean
)
select customer_id,changes,count(changes) count from new_table
group by customer_id,changes;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT 
    COUNT(*) AS count
FROM
    customer_orders_clean
WHERE
    exclusions IS NOT NULL
        AND extras IS NOT NULL;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    EXTRACT(HOUR FROM order_time) AS order_hour,
    COUNT(*) AS total_pizzas
FROM
    customer_orders_clean
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY order_hour;

-- What was the volume of orders for each day of the week?
SELECT 
    FORMAT(order_time, 'yyyy-MM-dd') AS Days,
    COUNT(*) AS total_pizzas
FROM
    customer_orders_clean
GROUP BY FORMAT(order_time, 'yyyy-MM-dd')
ORDER BY Days;