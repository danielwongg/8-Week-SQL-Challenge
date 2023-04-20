--Case Study #1 - Danny's Diner



--Schema/Database Creation
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  


--Question 1
SELECT sales.customer_id, SUM(price) AS total_sales
FROM sales
JOIN menu
ON sales.product_id=menu.product_id
GROUP BY customer_id
ORDER BY customer_id;


--Question 2
SELECT sales.customer_id, COUNT(DISTINCT(order_date)) as times_visited
FROM sales
GROUP BY customer_id;


--Question 3
WITH order_ranked AS
(
    SELECT customer_id, order_date, product_name,
    DENSE_RANK() OVER(PARTITION BY sales.customer_id
    ORDER BY sales.order_date)
    AS ranking
    FROM sales
    JOIN menu
    ON sales.product_id=menu.product_id
)

SELECT customer_id, product_name
FROM order_ranked
WHERE ranking = 1
GROUP BY customer_id, product_name;


--Question 4
SELECT product_name, COUNT(sales.product_id) AS times_ordered
FROM sales
JOIN menu
ON sales.product_id=menu.product_id
GROUP BY sales.product_id, product_name
ORDER BY COUNT(sales.product_id) DESC;


--Question 5
WITH most_ordered AS
(
    SELECT sales.customer_id, product_name, COUNT(sales.product_id) AS times_ordered,
    DENSE_RANK() OVER (PARTITION BY sales.customer_id
    ORDER BY COUNT(sales.product_id) DESC)
    AS ranking
    FROM sales
    JOIN menu
    ON sales.product_id=menu.product_id
    GROUP BY sales.customer_id, menu.product_name
)

SELECT customer_id, product_name, times_ordered
FROM most_ordered
WHERE ranking = 1;


--Question 6
WITH date_rank AS
(
    SELECT sales.customer_id, order_date, join_date, product_name,
    ROW_NUMBER() OVER(PARTITION BY sales.customer_id
    ORDER BY order_date)
    AS ranking
    FROM sales
    JOIN members
    ON sales.customer_id=members.customer_id
    JOIN menu
    ON sales.product_id=menu.product_id
    WHERE order_date>=join_date
)

SELECT customer_id, product_name, order_date
FROM date_rank
WHERE ranking = 1
ORDER BY customer_id;


--Question 7
WITH date_rank AS
(
    SELECT sales.customer_id, order_date, join_date, product_name,
    DENSE_RANK() OVER(PARTITION BY sales.customer_id
    ORDER BY order_date DESC)
    AS ranking
    FROM sales
    JOIN members
    ON sales.customer_id=members.customer_id
    JOIN menu
    ON sales.product_id=menu.product_id
    WHERE order_date<join_date
)

SELECT customer_id, product_name, order_date, join_date
FROM date_rank
WHERE ranking = 1;


--Question 8
SELECT sales.customer_id, COUNT(product_name) AS total_items, SUM(price) AS total_spent
FROM sales
JOIN menu
ON menu.product_id = sales.product_id
JOIN members
ON members.customer_id = sales.customer_id
WHERE order_date < join_date
GROUP BY sales.customer_id
ORDER BY sales.customer_id;


--Question 9
SELECT sales.customer_id,
SUM(CASE
WHEN product_name = 'sushi' THEN price * 20
ELSE price * 10
END) AS points
FROM menu
JOIN sales
ON sales.product_id=menu.product_id
GROUP BY sales.customer_id;


--Question 10
SELECT sales.customer_id,
SUM(CASE
WHEN product_name = 'sushi' THEN price * 20
WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 7 DAY) THEN price * 20
ELSE price * 10
END) AS points
FROM menu
JOIN sales
ON sales.product_id=menu.product_id
JOIN members
ON sales.customer_id=members.customer_id
WHERE order_date<=LAST_DAY('2021-01-01')
GROUP BY sales.customer_id
ORDER BY sales.customer_id;



--Bonus Question 1
SELECT sales.customer_id, order_date, product_name, price,
CASE
WHEN order_date < join_date THEN 'N'
WHEN join_date IS NULL THEN 'N'
ELSE 'Y'
END AS member
FROM sales
LEFT JOIN members
ON sales.customer_id = members.customer_id
JOIN menu
ON sales.product_id = menu.product_id
ORDER BY sales.customer_id , order_date , product_name;


--Bonus Question 2
WITH ranks_cte AS
(
    SELECT sales.customer_id, order_date, product_name, price,
    CASE
    WHEN order_date < join_date THEN 'N'
    WHEN join_date IS NULL THEN 'N'
    ELSE 'Y'
    END AS member
    from sales
    LEFT JOIN members
    ON sales.customer_id = members.customer_id
    JOIN menu
    ON sales.product_id = menu.product_id
    ORDER BY sales.customer_id , order_date , product_name
)

SELECT *,
CASE
WHEN member = 'N' THEN NULL
ELSE
DENSE_RANK() OVER(PARTITION BY sales.customer_id, member
ORDER BY order_date)
END AS ranking
FROM ranks_cte;


