-- What are the standard ingredients for each pizza?
SELECT 
    pr.pizza_name,
    pt.topping_name
FROM pizza_recipes pr
JOIN JSON_TABLE(
    CONCAT('[', pr.toppings, ']'),
    "$[*]" COLUMNS(topping_id INT PATH "$")
) AS jt
ON jt.topping_id = pt.topping_id
JOIN pizza_toppings pt
ON jt.topping_id = pt.topping_id
ORDER BY pr.pizza_id, pt.topping_id;
-- What was the most commonly added extra?

with new_table as (select * from customer_orders_clean
JOIN JSON_TABLE(
    CONCAT('[', extras , ']'),
    "$[*]" COLUMNS(topping_id INT PATH "$")
) AS jt)

select n.topping_id, pt.topping_name  from new_table n
Left join pizza_toppings pt
ON n.topping_id = pt.topping_id
group by n.topping_id,pt.topping_name; 


-- What was the most common exclusion?
SELECT 
    pt.topping_name,
    COUNT(*) AS count
FROM customer_orders_clean c
JOIN JSON_TABLE(
    CONCAT('[', c.exclusions, ']'),
    "$[*]" COLUMNS(topping_id INT PATH "$")
) jt
LEFT JOIN pizza_toppings pt 
    ON jt.topping_id = pt.topping_id
GROUP BY jt.topping_id, pt.topping_name
ORDER BY count DESC
LIMIT 1;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- SELECT 
--    c.order_id,
--    jt.topping_id
-- FROM customer_orders_clean c
-- JOIN JSON_TABLE(
--     CONCAT('[', c.exclusions, ']'),
--     "$[*]" COLUMNS(topping_id INT PATH "$")
-- ) jt

-- UNION

-- SELECT 
--    c.order_id,
--    jt.topping_id
-- FROM customer_orders_clean c
-- JOIN JSON_TABLE(
--     CONCAT('[', c.extras, ']'),
--     "$[*]" COLUMNS(topping_id INT PATH "$")
-- ) jt;
with final_table as(
(with topping_table as (SELECT 
    *
FROM pizza_recipes pr
JOIN JSON_TABLE(
    CONCAT('[', pr.toppings, ']'),
    "$[*]" COLUMNS(topping_id INT PATH "$")
) AS jt)

select pt.topping_name as topping,
count(pt.topping_name) count
from customer_orders_clean c
left join topping_table t
on c.pizza_id=t.pizza_id
JOIN JSON_TABLE(
    CONCAT('[', c.exclusions, ']'),
    "$[*]" COLUMNS(exclusion_id INT PATH "$")
) jt
LEFT JOIN pizza_toppings pt 
ON t.topping_id = pt.topping_id
where t.topping_id!=exclusion_id
group by pt.topping_name
order by count desc)

union

(with topping_table_2 as (select * from customer_orders_clean c
JOIN JSON_TABLE(
    CONCAT('[', extras, ']'),
    "$[*]" COLUMNS(topping_id INT PATH "$")
) jt)

select pt.topping_name as topping,
count(pt.topping_name) count
 from topping_table_2 as t
LEFT JOIN pizza_toppings pt 
ON t.topping_id = pt.topping_id
group by pt.topping_name
order by count desc))

-- select topping,sum(count) as count from final_table
-- group by topping order by count desc;
select * from final_table;


