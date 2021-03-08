-- Rolling calculations lab

-- 1. Get number of monthly active customers

SELECT  distinct date_format(convert(return_date,date), '%M') as Month, count(active) as Monthly_active_users
FROM sakila.customer as customer_table 
LEFT JOIN sakila.rental as rental_table on customer_table.customer_id = rental_table.rental_id
WHERE date_format(convert(return_date,date), '%M') is not null
GROUP BY Month;

-- 2. Active users in the previous month - done in the previous query
-- 3. Percentage change in the number of active customers

-- first I create a last_month column...

CREATE TABLE active_users
SELECT Month, Monthly_active_users, lag(Monthly_active_users) over (order by Month) as Last_month
FROM (SELECT  distinct date_format(convert(return_date,date), '%M') as Month, count(active) as Monthly_active_users
FROM sakila.customer as customer_table 
LEFT JOIN sakila.rental as rental_table on customer_table.customer_id = rental_table.rental_id
WHERE date_format(convert(return_date,date), '%M') is not null
GROUP BY Month) as sub1;

-- Then I calculate the % change in number of customers

with cte_view as (
SELECT Month, Monthly_active_users, lag(Monthly_active_users) over (order by Month) as Last_month
FROM (SELECT  distinct date_format(convert(return_date,date), '%M') as Month, count(active) as Monthly_active_users
FROM sakila.customer as customer_table 
LEFT JOIN sakila.rental as rental_table on customer_table.customer_id = rental_table.rental_id
WHERE date_format(convert(return_date,date), '%M') is not null
GROUP BY Month) as sub1 
)
SELECT Month, Monthly_active_users, Last_month, ((Monthly_active_users - Last_month)/Last_month)*100 as per_change
FROM cte_view;

-- 4. Retained customers every month.

-- getting the unique active users per month

SELECT distinct customer_table.customer_id as Active_id, date_format(convert(return_date,date), '%M') as Month 
FROM sakila.customer as customer_table 
LEFT JOIN sakila.rental as rental_table on customer_table.customer_id = rental_table.rental_id
WHERE date_format(convert(return_date,date), '%M') is not null AND active =1
GROUP BY Month, Active_id
ORDER BY Month, Active_id;

SELECT count(Active_id) as unique_users, Month
FROM (SELECT distinct customer_table.customer_id as Active_id, date_format(convert(return_date,date), '%M') as Month 
FROM sakila.customer as customer_table 
LEFT JOIN sakila.rental as rental_table on customer_table.customer_id = rental_table.rental_id
WHERE date_format(convert(return_date,date), '%M') is not null AND active =1
GROUP BY Month, Active_id
ORDER BY Month, Active_id) as sub1
GROUP BY Month;

CREATE TABLE unique_users
SELECT Month, unique_users, lag(unique_users) over (order by Month) as Last_month2
FROM (SELECT count(Active_id) as unique_users, Month
FROM (SELECT distinct customer_table.customer_id as Active_id, date_format(convert(return_date,date), '%M') as Month 
FROM sakila.customer as customer_table 
LEFT JOIN sakila.rental as rental_table on customer_table.customer_id = rental_table.rental_id
WHERE date_format(convert(return_date,date), '%M') is not null AND active =1
GROUP BY Month, Active_id
ORDER BY Month, Active_id) as sub1
GROUP BY Month) as sub;

-- I join both tables

SELECT unique_users_table.Month,Monthly_active_users,Last_month,unique_users,Last_month2
FROM unique_users as unique_users_table 
JOIN active_users as active_users_table on unique_users_table.month = active_users_table.month;

-- not really sure about how to get the final result...will ask in class


