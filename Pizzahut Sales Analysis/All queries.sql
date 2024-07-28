/*Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category. */

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS total_sales
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, SUM(od.quantity) AS total_qty
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_qty DESC;

-- Top 5 most ordered pizza type with their quantities
SELECT 
    pt.name,
    pt.pizza_type_id,
    SUM(od.quantity) AS total_qty
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name , pt.pizza_type_id
ORDER BY total_qty DESC
LIMIT 5;

-- Total quantities of each pizza category ordered
SELECT 
    pt.category, SUM(od.quantity) AS total_qty
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_qty DESC;

-- Distribution of orders by hour of the day
SELECT 
    HOUR(time) AS time_hour, COUNT(order_id) AS total_order
FROM
    orders
GROUP BY time_hour
ORDER BY total_order DESC;

-- Category wise distribution of pizza
SELECT 
    pt.category,
    SUM(od.quantity) / (SELECT 
            SUM(quantity)
        FROM
            order_details) * 100 AS distribution_category
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Average pizza ordered per day
SELECT 
    AVG(total_orders) AS avg_order_per_day
FROM
    (SELECT 
        o.date AS day_, SUM(od.quantity) AS total_orders
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY day_
    ORDER BY day_) AS t1;

-- Top 3 most ordered pizza type based on revenue
SELECT 
    pt.name,
    p.pizza_type_id,
    SUM(p.price * od.quantity) AS total_revenue
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.pizza_type_id , pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Analyze the cumulative revenue generated over time
SELECT date, sum(total_revenue) over(order by date) as cum_total_revenue
from
(SELECT 
    o.date,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY o.date) as sales;

-- Top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category, name, revenue, rank_
from
(SELECT category, name, revenue, rank() over(partition by category order by revenue desc) as rank_
from 
(SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY pt.category , pt.name) as T1) as T2
where rank_<=3;