# Case Study #2 - Pizza Runner

***All data has been cleaned before proceeding with questions - the created temporary tables with the cleaned data is being used over the original tables***

## Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
SELECT COUNT(order_id) AS pizzas_ordered
FROM temp_customer_orders;
````
#### Reasoning
-  Each row from the ```temp_customer_orders``` table corresponds to one pizza as stated in the case study
-  Use a **COUNT** function to count the number of rows, in this csae ```order_id``` was used

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233735953-9ab125be-c447-4d2f-bc66-2fd591e47be1.png)

From the query above, there have been 14 pizzas ordered.

### 2. How many unique customer orders were made?

````sql
SELECT COUNT(DISTINCT(order_id)) AS orders_made
FROM temp_customer_orders;
````

#### Reasoning
-  Similar to the previous question, a **COUNT** function is used on ```order_id```, but this time together with a **DISTINCT** function as we wish to find each unique order ID

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233735978-f289bdbe-4152-4b3c-b049-a08c27c108ba.png)

From the query above there have been 10 unique orders made.

### 3. How many successful orders were delivered by each runner?

````sql
SELECT runner_id, COUNT(pickup_time) AS orders_delivered
FROM temp_runner_orders
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
````

#### Reasoning
- A **COUNT** function with a **WHERE** clause that states that ```pickup_time``` cannot be **NULL** counts the numbers of orders that have been picked up and delivered by runners
- Results are then ordered with a **GROUP BY** command with ```runner_id``` to discern how many successful pickups and deliveries were made by each runner

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233737261-1fc65233-2edb-4726-a0f9-770297cad431.png)

From the query above, runner 1 made 4 deliveries, runner 2 made 3 deliveries, and runner 3 made 1 delivery.

### 4. How many of each type of pizza was delivered?

````sql
SELECT pizza_name, COUNT(temp_customer_orders.pizza_id) AS pizza_count
FROM temp_customer_orders
JOIN temp_runner_orders
ON temp_runner_orders.order_id=temp_customer_orders.order_id
JOIN pizza_names
ON temp_customer_orders.pizza_id=pizza_names.pizza_id
WHERE pickup_time IS NOT NULL
GROUP BY pizza_name;
````

#### Reasoning
- Two **JOIN** functions must be used to join the ```temp_runner_orders``` and ```pizza_names``` tables to the ```temp_customer_orders``` table
- A **COUNT** function on the ```pizza_id``` column is used with a **GROUP BY** on ```pizza_name``` to count the number of pizzas successfully delivered based on the pizza name
- Ensure to only count successful deliveries with a **WHERE** clause that only counts if ```pickup_time``` is not **NULL**

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233739325-82a5ff0e-6e6a-4565-a5b1-1b0836d26c10.png)

From the query above, Meat Lovers pizza was delivered 9 times, and Vegetarian pizza was delivered 3 times.

### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
SELECT customer_id, pizza_name, COUNT(temp_customer_orders.pizza_id) AS pizza_count
FROM temp_customer_orders
JOIN temp_runner_orders
ON temp_runner_orders.order_id=temp_customer_orders.order_id
JOIN pizza_names
ON temp_customer_orders.pizza_id=pizza_names.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;
````

#### Reasoning
- Use the same query as the previous question, but inserting ```customer_id``` into the **SELECT**, **GROUP BY**, and **ORDER BY** functions
- Eliminate the **WHERE** clause as the orders do not need to be delivered, only ordered

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233739978-908055de-d971-48d7-9480-5a2d1c00ff33.png)

From the query above:
- Customer 101 made 2 Meat Lovers and 1 Vegetarian orders
- Customer 102 made 2 Meat Lovers and 1 Vegetarian orders
- Customer 103 made 3 Meat Lovers and 1 Vegetarian orders
- Customer 104 made 3 Meat Lovers orders
- Customer 105 made 1 Vegetarian order

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
WITH most_ordered_cte AS
(
	SELECT temp_customer_orders.order_id, COUNT(temp_customer_orders.pizza_id) AS pizza_count
	FROM temp_customer_orders
	JOIN temp_runner_orders
	ON temp_runner_orders.order_id=temp_customer_orders.order_id
	WHERE pickup_time IS NOT NULL
	GROUP BY temp_customer_orders.order_id
)

SELECT MAX(pizza_count) AS largest_order
FROM most_ordered_cte;
````

#### Reasoning
- Use the same query as question #4 but replace ```pizza_name``` with ```order_id``` and eliminate the **JOIN** of the ```pizza_names``` table, this change counts the number of pizzas per order
- Ensure to only count successful deliveries with a **WHERE** clause that only counts if ```pickup_time``` is not **NULL**
- Insert that query into a CTE, and use a **MAX** function on ```pizza_count``` to find the largest number of pizzas in a single order in another **SELECT** statement

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233741588-ec4e4a8a-5509-4e35-b358-3adb84eaa431.png)

From the query above the largest number of pizzas delivered in a single order is 3.

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT temp_customer_orders.customer_id,
SUM(CASE
WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN '1'
ELSE '0'
END) AS changes,
SUM(CASE
WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN '0'
ELSE '1'
END) AS no_changes
FROM temp_customer_orders
JOIN temp_runner_orders
ON temp_runner_orders.order_id = temp_customer_orders.order_id
WHERE pickup_time IS NOT NULL
GROUP BY temp_customer_orders.customer_id;
````

#### Reasoning
- Need to fined number of orders delivered, so we can use the same query as question #4 but replace ```pizza_name``` with ```order_id``` and eliminate the **JOIN** of the ```pizza_names``` table
- Use two different **SUM** functions with **CASE** statements within each one
- To see how many pizzas were changed, use an **OR** function within the **CASE** statement to check if ```exclusions``` or ```extras``` is not null, if so the result is = 1, otherwise result = 0. This way when we **SUM**, if either ```exclusions``` or ```extras``` returns a value it is counted as one pizza with changes made towards the **SUM**
- The reverse is done for the **SUM** for no changes; if ```exclusions``` or ```extras``` is not null, then the value returned = 0, otherwise value = 1. This way when we **SUM**, only pizzas that have null values in ```exclusions``` or ```extras```will have value = 1

#### Answer:

![image](https://user-images.githubusercontent.com/130705459/233753776-8fba311b-5b7f-4320-a797-49421f21d1dc.png)

From the query above:
- Customer 101 ordered 2 pizzas with no changes
- Customer 102 ordered 3 pizzas with no changes
- Customer 103 ordered 3 pizzas with at least one change
- Customer 104 ordered 1 pizza with no changes and 2 pizzas with at least one change
- Customer 105 ordered 1 pizza with at least one change


