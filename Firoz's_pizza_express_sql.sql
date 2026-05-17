-- ==========================================================
-- 1. Runners
-- ==========================================================
CREATE TABLE runners (
  runner_id SERIAL PRIMARY KEY,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date) VALUES
(1, '2025-06-01'),
(2, '2025-06-05'),
(3, '2025-06-10'),
(4, '2025-06-15');

select * from runners

-- ==========================================================
-- 2. Pizza Names
-- ==========================================================
CREATE TABLE pizza_names (
  pizza_id SERIAL PRIMARY KEY,
  pizza_name VARCHAR(50)
);

INSERT INTO pizza_names (pizza_id, pizza_name) VALUES
(1, 'Margherita'),
(2, 'Paneer Tikka');

select * from pizza_names


-- ==========================================================
-- 3. Pizza Ingredients (master list)
-- ==========================================================
CREATE TABLE ingredients (
  ingredient_id SERIAL PRIMARY KEY,
  ingredient_name VARCHAR(50)
);

INSERT INTO ingredients (ingredient_id, ingredient_name) VALUES
(1, 'Cheese'),
(2, 'Tomato'),
(3, 'Basil'),
(4, 'Paneer'),
(5, 'Capsicum'),
(6, 'Olives');

select * from pizza_ingredients

-- ==========================================================
-- 4. Pizza Recipes (mapping pizzas to ingredients)
-- ==========================================================
CREATE TABLE pizza_recipes (
  pizza_id INT,
  ingredient_id INT,
  PRIMARY KEY (pizza_id, ingredient_id),
  FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id),
  FOREIGN KEY (ingredient_id) REFERENCES pizza_ingredients(ingredient_id)
);

INSERT INTO pizza_recipes (pizza_id, ingredient_id) VALUES
(1, 1), -- Margherita -> Cheese
(1, 2), -- Margherita -> Tomato
(1, 3), -- Margherita -> Basil
(2, 1), -- Paneer Tikka -> Cheese
(2, 4), -- Paneer Tikka -> Paneer
(2, 5); -- Paneer Tikka -> Capsicum

select * from pizza_recipes


-- ==========================================================
-- 5. Customer Orders
-- ==========================================================
CREATE TABLE customer_orders (
  order_item_id SERIAL PRIMARY KEY,
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(100),
  extras VARCHAR(100),
  order_time TIMESTAMP,
  FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id)
);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
(1, 201, 1, '', '', '2025-06-20 18:00:00'),
(2, 202, 1, '', '', '2025-06-20 18:05:00'),
(3, 203, 2, '', '5', '2025-06-21 19:30:00'),
(3, 203, 1, '4', '', '2025-06-21 19:30:00'),
(4, 204, 2, '', '', '2025-06-22 20:00:00'),
(5, 205, 1, '4', '5', '2025-06-22 21:15:00'),
(6, 202, 2, '', '6', '2025-06-23 17:45:00'),
(7, 206, 1, '', '', '2025-06-23 18:30:00'),
(8, 207, 2, '', '1,6', '2025-06-23 19:15:00');




-- ==========================================================
-- 6. Runner Orders (delivery info, one row per order_id)
-- ==========================================================
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time TIMESTAMP,
  distance_km NUMERIC(5,2),
  duration_mins INT,
  cancellation VARCHAR(50),
  FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance_km, duration_mins, cancellation) VALUES
(1, 1, '2025-06-20 18:10:00', 5.2, 15, ''),
(2, 2, '2025-06-20 18:15:00', 3.8, 12, ''),
(3, 1, '2025-06-21 19:40:00', 7.5, 20, ''),
(4, 3, NULL, NULL, NULL, 'Restaurant cancelled'),
(5, 4, '2025-06-22 21:25:00', 4.5, 14, ''),
(6, 2, '2025-06-23 17:55:00', 6.0, 18, ''),
(7, 3, '2025-06-23 18:40:00', 2.5, 9, ''),
(8, 1, '2025-06-23 19:25:00', 8.2, 22, '');


--A. Runner Activity Metrics
--1. How many runners signed up each week? (Assume week starts Monday.)
SELECT
    DATE_TRUNC('week', registration_date) AS week_start,
    COUNT(*) AS total_runners
FROM runners
GROUP BY week_start
ORDER BY week_start;

--2. What's the average time (in minutes) between runner registration and their fi rst pickup?
SELECT
    AVG(
        EXTRACT(EPOCH FROM (first_pickup - registration_date)) / 60
    ) AS avg_minutes
FROM (
    SELECT
        r.runner_id,
        r.registration_date,
        MIN(ro.pickup_time) AS first_pickup
    FROM runners r
    JOIN runner_orders ro
    ON r.runner_id = ro.runner_id
    WHERE ro.pickup_time IS NOT NULL
    GROUP BY r.runner_id, r.registration_date
) t;


--3. What’s the successful delivery count per runner?
SELECT
    runner_id,
    COUNT(*) AS successful_deliveries
FROM runner_orders
WHERE cancellation IS NULL
   OR cancellation = ''
GROUP BY runner_id
ORDER BY runner_id;


--4. Delivery success rate per runner (ratio of non-cancelled to total assigned orders)?
SELECT
    runner_id,
	ROUND(COUNT(CASE WHEN cancellation = '' THEN 1 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id;

--5. Average speed per runner (distance/duration); any noticeable trends?
SELECT 
	runner_id,
	ROUND(AVG(distance_km / (duration_mins / 60.0)),2) AS avg_speed_kmph
FROM runner_orders
WHERE cancellation = ''
GROUP BY runner_id
ORDER BY runner_id;

--B. Order & Delivery Insights
--1. Total number of pizzas ordered.
SELECT COUNT(*) AS total_pizzas
FROM customer_orders;


--2. Unique customer orders count.
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;


--3. Average waiting time (order_time to pickup_time) for successful deliveries.
SELECT
AVG(EXTRACT(EPOCH FROM (pickup_time - order_time))/60) AS avg_waiting_time
FROM (
    SELECT DISTINCT
    co.order_id,
    co.order_time,
    ro.pickup_time
    FROM customer_orders co
    JOIN runner_orders ro
    ON co.order_id = ro.order_id
    WHERE ro.cancellation = ''
) t;

--4. Difference between longest and shortest delivery durations.
SELECT
MAX(duration_mins) - MIN(duration_mins) AS duration_difference
FROM runner_orders
WHERE cancellation = '';

--C. Ingredient Optimization
--1. List standard ingredients per pizza (by name).
SELECT
pn.pizza_name,
STRING_AGG(i.ingredient_name, ', ') AS ingredients
FROM pizza_recipes pr
JOIN pizza_names pn
ON pr.pizza_id = pn.pizza_id
JOIN ingredients i
ON pr.ingredient_id = i.ingredient_id
GROUP BY pn.pizza_name;

--2. Most commonly added extra ingredient (name).
SELECT
i.ingredient_name,
COUNT(*) AS total_added
FROM customer_orders co
JOIN ingredients i
ON CAST(i.ingredient_id AS TEXT) = ANY(string_to_array(co.extras, ','))
WHERE co.extras <> ''
GROUP BY i.ingredient_name
ORDER BY total_added DESC
LIMIT 1;


--3. Most commonly excluded ingredient.
SELECT
i.ingredient_name,
COUNT(*) AS total_excluded
FROM customer_orders co
JOIN ingredients i
ON CAST(i.ingredient_id AS TEXT) = ANY(string_to_array(co.exclusions, ','))
WHERE co.exclusions <> ''
GROUP BY i.ingredient_name
ORDER BY total_excluded DESC
LIMIT 1;

--4. Total count of each ingredient used in delivered pizzas, sorted descending.
SELECT
i.ingredient_name,
COUNT(*) AS total_used
FROM customer_orders co
JOIN runner_orders ro
ON co.order_id = ro.order_id
JOIN pizza_recipes pr
ON co.pizza_id = pr.pizza_id
JOIN ingredients i
ON pr.ingredient_id = i.ingredient_id
WHERE ro.cancellation = ''
AND (co.exclusions = '' OR CAST(i.ingredient_id AS TEXT) != ALL(string_to_array(co.exclusions, ',')))
GROUP BY i.ingredient_name
ORDER BY total_used DESC;

