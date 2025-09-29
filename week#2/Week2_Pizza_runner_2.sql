-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)



SELECT 
    ro.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE,
        o.order_time,
        ro.pickup_time)) AS avg_pickup_minutes
FROM
    customer_orders o
        JOIN
    runner_orders ro ON o.order_id = ro.order_id
WHERE
    ro.pickup_time IS NOT NULL
GROUP BY ro.runner_id
ORDER BY ro.runner_id;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT 
    o.customer_id,
    COUNT(o.customer_id) AS count,
    AVG(TIMESTAMPDIFF(MINUTE,
        o.order_time,
        ro.pickup_time)) AS preptime
FROM
    customer_orders o
        JOIN
    runner_orders ro ON o.order_id = ro.order_id
GROUP BY o.customer_id
ORDER BY o.customer_id;

-- select distinct count(*) from customer_orders group by customer_id,pizza_id; 


SELECT 
    o.customer_id, ROUND(AVG(ro.distance), 2) AS Distance
FROM
    customer_orders o
        JOIN
    runner_orders ro ON o.order_id = ro.order_id
GROUP BY o.customer_id;


-- What was the difference between the longest and shortest delivery times for all orders?
with temp as
(SELECT 
    (REPLACE(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'mins', ''), 'min', ''), 'minute', '')) AS time_only
FROM runner_orders)
select Max(time_only)-Min(time_only) as difference from temp where time_only!='null';


-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    runner_id, ROUND(AVG(distance * 60 / duration), 2) AS speed
FROM
    runner_orders
WHERE
    distance IS NOT NULL
GROUP BY runner_id;-- By doing above query it seems like runner with id 2 is slowest and 3 is fastest


SELECT 
    runner_id,
    ROUND(SUM(CASE
                WHEN distance != 'null' THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),
            2) AS success_percentage
FROM
    runner_orders
GROUP BY runner_id;

