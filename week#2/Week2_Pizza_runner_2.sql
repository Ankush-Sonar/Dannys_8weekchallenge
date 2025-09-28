-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)



-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
    ro.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE, o.order_time, ro.pickup_time)) AS avg_pickup_minutes
FROM customer_orders o
JOIN runner_orders ro
ON o.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY ro.runner_id
ORDER BY ro.runner_id;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
select distinct count(*) as count, AVG(TIMESTAMPDIFF(MINUTE, o.order_time, ro.pickup_time)) as preptime
FROM customer_orders o
JOIN runner_orders ro
ON o.order_id = ro.order_id
group by o.customer_id,o.pizza_id;

select distinct count(*) from customer_orders group by customer_id,pizza_id; 


-- What was the average distance travelled for each customer?
SELECT o.customer_id, Round(AVG(ro.distance),2) as Distance
FROM customer_orders o
JOIN runner_orders ro
ON o.order_id = ro.order_id
group by o.customer_id;


-- What was the difference between the longest and shortest delivery times for all orders?

with temp as
(SELECT 
    (REPLACE(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'mins', ''), 'min', ''), 'minute', '')) AS time_only
FROM runner_orders)
select Max(time_only)-Min(time_only) as difference from temp where time_only!='null';

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?