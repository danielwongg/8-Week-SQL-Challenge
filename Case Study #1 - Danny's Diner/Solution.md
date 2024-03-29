## Solutions

### 1. What is the total amount each customer spent at the restaurant?
```sql
SELECT sales.customer_id, SUM(price) AS total_sales
FROM sales
JOIN menu
ON sales.product_id=menu.product_id
GROUP BY customer_id
ORDER BY customer_id;
```
#### Reasoning
-  Find total amount spent using the **SUM** function
-  Use **JOIN** function to combine two seperate tables that contain the information necessary to complete the query (```product_id``` and ```price```)
-  To sort by each customer, utilize the **GROUP BY** function
-  The **ORDER BY** function is used to further sort the query by ```customer_id``` 

#### Answer:
| customer_id | total_sales  |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

From the query above we see that customer A spent $76,  customer B spent $74, and customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

```sql
SELECT sales.customer_id, COUNT(DISTINCT(order_date)) AS times_visited
FROM sales
GROUP BY customer_id;
```

#### Reasoning
- All information required to answer the question is in the Sales table (```customer_id``` and ```order-date```)
- To figure out number of days visited, I used the **DISTINCT** and **COUNT** functions. This filters out multiple orders on the same day, and converts each order date into a numerical  value that represents times visited
- Filter the results by ```customer_id``` to see the number of times each customer visited

#### Answer:
| customer_id | times_visited |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

From the query above we see that customer A visited 4 times, customer B visited 6 times, and customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
````

#### Reasoning
- Using a **MIN** function on ```order_date``` combined with the ```product_name``` would not work as it would provide me the the earliest time each customer ordered each menu item, rather than the first item they had ordered
- Creating a CTE with a **DENSE_RANK** function, a **PARTITION BY** function, and a **ORDER_BY** function provides each product ordered by the customer to be assigned a rank, seperated by ```customer_id```
- **DENSE_RANK** is used instead of **RANK** as the data does not indicate which product was ordered earlier on the same date
- Using the CTE, I then can filter the first product ordered by each customer based on ranking = 1, and a following **GROUP BY** of ```customer_id``` and ```product_name```

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | sushi        | 
| A           | curry        | 
| B           | curry        | 
| C           | ramen        |

From the above query, customer A's first orders are sushi and curry, customer B's first order is curry, and customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT product_name, COUNT(sales.product_id) AS times_ordered
FROM sales
JOIN menu
ON sales.product_id=menu.product_id
GROUP BY sales.product_id, product_name
ORDER BY COUNT(sales.product_id) DESC;
````

#### Reasoning
- Conduct a **COUNT** of ```product_id``` for the number of orders made by customers
- **GROUP BY** ```product_name``` to seperate how many times each product was ordered
- Use **ORDER BY** in descending order to identify which product was ordered the most

#### Answer:
| product_name | times_ordered | 
| ----------- | ----------- |
| ramen       | 8	 |
| curry       | 4	 |
| sushi       | 3	 |


From the query above, we see that the most ordered product is ramen, with 8 orders total.

***

### 5. Which item was the most popular for each customer?

````sql
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

SELECT customer_id, product_name, TimesOrdered
FROM most_ordered
WHERE ranking = 1;
````

#### Reasoning
- Similar to question #3, I created a CTE that uses **DENSE_RANK** to rank the number of times a product was ordered based on a similar table in question #4
- I seperate the values/rankings with a **PARTITION BY** function on the ```customer_id``` and use a **ORDER BY** descending function on ```product_id```
- I then further restrict the values to return only when the rank = 1 so that I don't return products ordered less(ie. a rank not equalt to 1)

#### Answer:
| customer_id | product_name | times_ordered |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | curry        |  2   |
| B           | sushi        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

From the query above, we see that customer A's most ordered product is ramen, customer B's most ordered product is an equal amount of curry, sushi, and ramen, and customer C's most ordered product is ramen.

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH date_rank AS
(
    SELECT sales.customer_id, order_date, sales.product_id, join_date, product_name,
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
````

#### Reasoning
- Create ```date_rank``` CTE and include a **ROW_NUMBER** function to give each row a value, seperated by ```customer_id``` and ordered by ```order_date``` in ascending order
- Join the ```members``` table and the ```menu``` table with the ```sales``` table so that we can filter the results to only when ```order_date``` is greater or equal to the ```join_date```
- Using the ```date_rank``` CTE, create a new select statement to further restrict the results to where the row number(labeled as ranking) is equal to 1 to show the first product ordered after becoming a member

#### Answer:
| customer_id | product_name | order_date |
| ----------- | ---------- |----------  |
| A           | curry    | 2021-01-07    |
| B           | sushi    | 2021-01-11    |

From the query above we see that the first product ordered by each customer after becoming a member was curry for customer A, and sushi for customer B.

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
````

#### Reasoning
- Similar to question 6, I used a CTE that ranks ```order_date``` but this time in descending order, seperated by ```customer_id```
- Join both ```menu``` and ```members``` tables to the ```sales``` table, and restrict results to show all ```order_date``` that are less than ```join_date```
- Using the CTE, create a new select statement to further restrict the results to where the row number(labeled as ranking) is equal to 1 to show the last product ordered before becoming a member

#### Answer:
| customer_id | product_name  | order_date | join_date |
| ----------- | ------ |--------------  | ------------|
| A           | sushi |  2021-01-01     | 2021-01-07  |
| A           | curry |  2021-01-01     | 2021-01-07  |
| B           | sushi |  2021-01-04     | 2021-01-09  |

From the query above, we see that customer A ordered both curry and sushi before becoming a member, and customer B ordered sushi before becoming a member.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT sales.customer_id, COUNT(product_name) AS total_items, SUM(price) AS total_spent
FROM sales
JOIN menu
ON menu.product_id=sales.product_id
JOIN members
ON members.customer_id=sales.customer_id
WHERE order_date<join_date
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
````

#### Reasoning
- Use **COUNT** on ```product_name``` and **SUM** on ```price``` to figure out the total number of products ordered and the total amount spent
- Join the ```menu``` and ```members``` table to the ```sales``` table, and restrict results for when ```order_date``` is less than the ```join_date```

#### Answer:
| customer_id | total_items | total_spent |
| ----------- | ---------- |----------  |
| A           | 2          |  25       |
| B           | 3          |  40       |

From the query above, we see that before becoming members, customer A spent $25 on 2 products, and customer B spent $40 on 3 products. Customer C never became a member, and therefore not included in the result set.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
SELECT sales.customer_id,
SUM(CASE
WHEN product_name = 'sushi' THEN price * 20
ELSE price * 10
END) AS points
FROM menu
JOIN sales
ON sales.product_id=menu.product_id
GROUP BY sales.customer_id;
````

#### Reasoning
- Use a **CASE** statement to seperate the different outcomes depending on ```product_name``` since sushi earns a different multiplier of points than other products
- **JOIN** the sales table and **SUM** the case statement to get the point totals for each ```customer_id```
- **GROUP BY** to order the results based on ```customer_id```

#### Answer:
| customer_id | points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

From the query above, customer A has 860 points, customer B has 940 points, and customer C has 360 points.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
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
````

#### Reasoning
- I chose to interpret the 2x points window as the member joining date, plus the full 7 days following; if the customer became a member on a Tuesday, their last day of the promotion would be the following Tuesday
- I also chose to interpret that sushi does not earn the promotion(ie. 4x the points), and the promotion only applies to products that aren't sushi
- Using a similar **CASE** statement as question #9, include an additional **WHEN** statement that provides the same multiplier on the price when the ```order_date``` is **BETWEEN** the ```join_date``` and the additional 7 days following
- All other results that do not fall within the two **WHEN** statements have their points tallied as normal
- Join both the ```sales``` and ```members``` tables to the ```menu``` table, and restrict all ```order_date``` to be less than or equal to the last day of January with a **LAST_DAY** function
- Use a **GROUP BY** function to organize the results as there was an aggregate function used

#### Answer:
| customer_id | points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 940 |

From the query above, we see that customer A earned 1370 points in the month of January, and customer B earned 940 points.

***

## BONUS QUESTIONS

### Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

![image](https://user-images.githubusercontent.com/130705459/233209853-7d35d735-af0c-416b-b321-3134f405928e.png)


````sql
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
 ````
 
#### Solution: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

#### Reasoning
- Use a **CASE** statement that creates the member column of the table - identify the cases when a customer is not a member, such as ```order_date``` is less than ```join_date```, and when ```join_date``` is null
- A **LEFT JOIN** is used on the ```members``` table instead of **JOIN** as all customers need to be present in the table, and customer C does not exist in the ```members``` table. A regular **JOIN** would not return customer C as it does not exist in the ```members``` table
- **JOIN** the menu table to get ```product_name``` and ```price``` columns, and then use an **ORDER BY** function to organize the table to match the example

***

### Rank All The Things - Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

![image](https://user-images.githubusercontent.com/130705459/233215428-20ea6a85-408a-45b8-89f2-2f972ed1d21c.png)


````sql
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
````

#### Solution: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL

#### Reasoning
- Since the ranking is based off member status and ```order_date```, the query in the previous bonus question can be used and put into a CTE
- Create a **CASE** statement that returns **NULL** when member status is equal to N - all other results are ranked
- To rank the other results, a **DENSE_RANK** function is used, seperated by ```customer_id``` and the ```member``` column from the CTE, and ranked by ```order_date``` ascending

***



