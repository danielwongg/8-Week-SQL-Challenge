Case Study #2 - Pizza Runner

## Data Cleaning & Transformation

From the [case study page](https://8weeksqlchallenge.com/case-study-2/), the instructions call for the data to be cleaned:

>"Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those null values and data types in the customer_orders and runner_orders tables!"

The following demonstrates how the data will be cleaned 

### Table: customer_orders

- Looking at the ```customer_orders``` table below, the ```exclusions``` and ```extras``` column both contain **NULL** values or text that states 'null'
- The data is not in a workable state as they are not uniform in nature

![image](https://user-images.githubusercontent.com/130705459/233496092-d1e12e97-af4f-4eb4-84af-bf8591f32d66.png)

In order to clean the date into a workable state:
- Create a temporary table mimicking the original ```customer_orders``` table with the projected fixes for the columns with issues
- Remove **NULL** values and 'null' text and replace them with a empty space
- Check that all data is the correct type(ie. date is not listed as VARCHAR), and adjust as needed for all columns

````sql
CREATE TEMPORARY TABLE temp_customer_orders AS
SELECT order_id, customer_id, pizza_id,
CASE
WHEN exclusions LIKE 'null' THEN NULL
WHEN exclusions IS NULL THEN NULL
WHEN exclusions LIKE '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras IS NULL THEN NULL
WHEN extras LIKE 'null' THEN NULL
WHEN extras LIKE '' THEN NULL 
ELSE extras
END AS extras,
order_time
FROM customer_orders;
`````

With the query above, this new ```temp_customer_orders``` table will be used instead of the ```customer_orders``` table to perform additional queries.

![image](https://user-images.githubusercontent.com/130705459/233533654-738d3672-7866-4fec-8071-32e27411139a.png)


***

### Table: runner_orders

- Looking at the `runner_orders` table below, the ```pivkup_time```, ```distance```, ```duration```, and ```cancellation``` columns are not uniformally formatted
- The columns contain **NULL** values, and differing text chains


![image](https://user-images.githubusercontent.com/130705459/233526017-45dd5a25-6b54-4cd0-b15e-ff1dcec246d6.png)

In order to clean the date into a workable state:
- Create a temporary table mimicking the original ```runner_orders``` table with the projected fixes for the columns with issues
- Remove **NULL** values and 'null' text and replace them with a empty space
- Use a **TRIM** function along with multiple **CASE** statements to make all text/units of measurement uniform
- Repeat as necessary for each respective column that requires cleaning
- Check that all data is the correct type(ie. date is not listed as VARCHAR), and adjust as needed for all columns

````sql
CREATE TEMPORARY TABLE temp_runner_orders AS
SELECT order_id, runner_id,
CASE
WHEN pickup_time IS NULL OR pickup_time LIKE 'null' THEN NULL
ELSE pickup_time
END AS pickup_time,
CASE
WHEN distance IS NULL THEN NULL
WHEN distance LIKE 'null' THEN NULL
WHEN distance LIKE '%km' THEN trim('km' FROM distance)
ELSE distance
END AS distance_km,
CASE
WHEN duration IS NULL THEN NULL
WHEN duration LIKE 'null' THEN NULL
WHEN duration LIKE '%minutes' THEN trim('minutes' FROM duration)
WHEN duration LIKE '%minute' THEN trim('minute' FROM duration)
WHEN duration LIKE '%mins' THEN trim('mins' FROM duration)
ELSE duration
END AS duration_minutes,
CASE
WHEN cancellation LIKE '' THEN NULL
WHEN cancellation LIKE 'null' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders;
````

Then, we alter the `pickup_time`, `distance` and `duration` columns to the correct data type.

````sql
ALTER TABLE temp_runner_orders
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance_km FLOAT,
MODIFY COLUMN duration_minutes INT;
````

With the query above, this new ```temp_rnner_orders``` table will be used instead of the ```runner_orders``` table to perform additional queries withing this case study.

![image](https://user-images.githubusercontent.com/130705459/233533699-524caa7c-a8a0-4456-81d6-08a958afb793.png)

***

Click here for INSERT SOLUTION LINK HERE
