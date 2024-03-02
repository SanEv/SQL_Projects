

-- 1. Find customers who have never ordered
USE zomato;
SELECT name FROM users
 WHERE user_id NOT IN
(SELECT user_id FROM orders);

-- 2. Average Price/dish
SELECT f.f_name, Avg(Price) AS 'Avg Price'
 FROM menu m
 JOIN food f
 ON m.f_id=f.f_id
GROUP BY m.f_id;
-- to find out which one is costly we can just sort it
SELECT f.f_name, Avg(Price) AS 'Avg Price'
 FROM menu m
 JOIN food f
 ON m.f_id=f.f_id
GROUP BY m.f_id
ORDER BY Avg(Price) desc;
-- 3. Find the top restaurant in terms of the number of orders for a given month
SELECT r.r_name, COUNT(*) AS 'Month' FROM orders o
JOIN restaurants r ON o.r_id=r.r_id
WHERE MONTHNAME(date) LIKE 'June'
GROUP BY o.r_id 
ORDER BY COUNT(*) desc LIMIT 1;

SELECT r.r_name, COUNT(*) AS 'Month' FROM orders o
JOIN restaurants r ON o.r_id=r.r_id
WHERE MONTHNAME(date) LIKE 'May'
GROUP BY o.r_id 
ORDER BY COUNT(*) desc LIMIT 1;

SELECT r.r_name, COUNT(*) AS 'Month' FROM orders o
 JOIN restaurants r ON o.r_id=r.r_id
 WHERE MONTHNAME(date) LIKE 'July'
 GROUP BY o.r_id
 ORDER BY COUNT(*) desc LIMIT 1;

-- 4. restaurants with monthly sales greater than x for 
SELECT r.r_name, SUM(amount) AS 'Revenue' FROM orders o
JOIN restaurants r ON r.r_id=o.r_id
WHERE MONTHNAME(date) LIKE 'June'
GROUP BY o.r_id
HAVING SUM(amount)>500;

-- 5. Show all orders with order details for a particular customer in a particular date range
--  we will filter our columns on the basis of user and date range.
-- Suppose user = Ankit and date range= 10 JUne to 10 July
 SELECT o.order_id, r.r_name,f.f_name
 FROM orders o
 JOIN restaurants r
 ON r.r_id=o.r_id
  JOIN order_details od
  ON o.order_id=od.order_id
  JOIN food f ON
  f.f_id=od.f_id
 WHERE user_id=
 (SELECT user_id FROM users WHERE name LIKE 'Ankit')
 AND date BETWEEN '2022-06-10' AND  '2022-07-10';
 
-- 6. Find restaurants with max repeated customers
 SELECT r.r_name, COUNT(*) AS 'loyal_customers'
 FROM
 ( 		SELECT r_id,user_id,COUNT(*) AS 'visits' FROM orders
		GROUP BY  r_id, user_id
		HAVING visits>1) t
JOIN restaurants r
ON r.r_id=t.r_id
GROUP BY r.r_id
ORDER BY loyal_customers DESC LIMIT 1;

-- 7. Month over month revenue growth of swiggy
SELECT month,((revenue-previous)/previous)*100 As 'Percentage'
FROM (WITH sales as (
				SELECT  MONTHNAME(date) AS 'month',SUM(amount) As 'revenue'
				FROM orders
				GROUP BY month)
SELECT month,revenue,LAG(revenue,1) 
OVER(ORDER BY revenue) AS 'previous'
FROM sales
 ) t;


-- 8. Customer - favorite food

WITH temp as 
		(SELECT o.user_id,od.f_id,COUNT(*) AS frequency 
			FROM orders o
			JOIN order_details od
			ON o.order_id=od.order_id
			GROUP BY o.user_id, od.f_id)
SELECT u.name,f.f_name FROM temp t1
JOIN users u 
ON u.user_id=t1.user_id
JOIN food f
ON f.f_id=t1.f_id
WHERE t1.frequency=
(SELECT MAX(frequency) 
FROM temp t2 WHERE t2.user_id=t1.user_id)

