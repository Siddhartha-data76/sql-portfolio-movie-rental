-- Date & Time Functions
USE mavenmovies;
-- 1. Show rental date and rental year from rental.
SELECT * FROM rental;
SELECT
	DATE(rental_date) AS rental_date,
    YEAR(rental_date) AS rental_Year
FROM rental;

-- 2. Show payment date and payment month from payment.
SELECT * FROM payment;
SELECT
	payment_date, 
    MONTH(payment_date) AS pay_month
FROM payment;

-- 3. Show rental date and weekday name.
SELECT * FROM rental;
SELECT
	rental_date,
    DAYNAME(rental_date) AS rental_week
FROM rental;

-- 4. Show payment date and hour of payment.
SELECT * FROM payment;
SELECT
	payment_date,
    HOUR(payment_date)
FROM payment;

SELECT
	payment_date,
    DATE_FORMAT(payment_date, '%h %p') AS hour_payment
FROM payment;

-- 5. Show only date part from payment_date.
SELECT * FROM payment;
SELECT
	DATE(payment_date) AS payment_date
FROM payment;

-- 6. Show customer create_date and month name.
SELECT * FROM customer;
SELECT
	create_date,
    MONTHNAME(create_date) AS month_name
FROM customer;

-- 7. Show all rentals with year = 2005
SELECT * FROM rental;
SELECT
	rental_id,
    YEAR(rental_date) AS rental_year
FROM rental
WHERE rental_date >= '2005-01-01'
AND rental_date < '2006-01-01';

-- 8. Show payments made in month August.
SELECT * FROM payment;
SELECT
	rental_id,
    amount,
    MONTH(payment_date) AS month_num,
    MONTHNAME(payment_date) AS month_name
FROM payment
WHERE
	payment_date >= '2005-08-01'
AND
	payment_date < '2005-09-01';
    
-- 9. Show rentals made on Sunday
SELECT * FROM rental;
SELECT
	rental_id,
    WEEKDAY(rental_date) AS week_num,
	DAYNAME(rental_date) AS week_name
FROM rental
WHERE DAYNAME(rental_date) = 'Sunday';

-- 10. Show payments made between 2005-06-01 and 2005-06-30
SELECT * FROM payment;
SELECT 
	payment_id,
    amount,
	payment_date
FROM payment
WHERE
	payment_date >= '2005-06-01'
AND
	payment_date < '2005-07-01';
    
-- 11. Show rentals after 2005-08-01
SELECT * FROM rental;
SELECT
	rental_id,
    rental_date
FROM rental
WHERE
	rental_date >= '2005-08-02';
    
-- 12. Show customers created in year 2006
SELECT * FROM customer;
SELECT
	customer_id,
    YEAR(create_date) AS create_year
FROM customer
WHERE YEAR(create_date) = 2006;

-- 13. Count rentals per year
SELECT * FROM rental;
SELECT
	YEAR(rental_date) AS rental_year,
	COUNT(*) AS cnt_rental
FROM rental
GROUP BY
	rental_year;

-- 14. Count payments per month
SELECT * FROM payment;
SELECT
	YEAR(payment_date) AS payment_year,
	MONTH(payment_date) AS payment_month,
	COUNT(*) AS cnt_payment
FROM payment
GROUP BY
	YEAR(payment_date),
	MONTH(payment_date)
ORDER BY payment_year, payment_month;

-- ALternative soution
SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
    COUNT(*) AS cnt_payment
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY payment_month;

-- 15. Find total revenue by weekday
SELECT * FROM payment;
SELECT
	YEAR(payment_date) AS payment_year,
    MONTH(payment_date) AS payment_month,
    WEEKDAY(payment_date) AS payment_week,
    SUM(amount) AS revenue
FROM payment
GROUP BY
	YEAR(payment_date),
    MONTH(payment_date),
    WEEKDAY(payment_date)
ORDER BY
	YEAR(payment_date),
    MONTH(payment_date),
    WEEKDAY(payment_date);
    
-- 16. Find total rentals by hour of day
SELECT * FROM rental;
SELECT
	HOUR(rental_date) AS hr_of_the_day,
    COUNT(*) AS ttl_rental
FROM rental
GROUP BY
	HOUR(rental_date)
ORDER BY
	HOUR(rental_date);
    
-- 17 Find days between rental_date and return_date
SELECT * FROM rental;
SELECT
	rental_id,
	DATEDIFF(return_date,rental_date) AS diff_date
FROM rental
WHERE return_date IS NOT NULL;

-- 18. Find rentals kept more than 7 days
SELECT
	rental_id,
    DATEDIFF(return_date, rental_date) AS rental_days
FROM rental
WHERE
	DATEDIFF(return_date, rental_date) > 7
AND
	return_date IS NOT NULL
ORDER BY rental_days;

-- 19. Find customers created in last 30 days from max create_date
SELECT * FROM customer;
SELECT
	customer_id,
    create_date
FROM customer
WHERE create_date BETWEEN
	(SELECT DATE_SUB(MAX(create_date), INTERVAL 30 DAY)
		FROM customer)
AND
	(SELECT MAX(create_date)
		FROM customer);
        
-- 20. Find months between first and last payment date
SELECT * FROM payment;
SELECT 
	TIMESTAMPDIFF(
		MONTH,
		MIN(payment_date),
		MAX(payment_date)
    ) AS months_diff
FROM payment;

-- Time and Date Functions Intermediate Level Questions
-- 1. Yearly Revenue Trend
SELECT * FROM payment;
SELECT
	YEAR(payment_date) AS payment_year,
    SUM(amount) AS Revenue
FROM payment
GROUP BY
	YEAR(payment_date);
    
-- 2. Monthly Revenue Trend
SELECT
	YEAR(payment_date) AS payment_year,
    MONTH(payment_date) AS payment_month,
    SUM(amount) AS Revenue
FROM payment
GROUP BY payment_year, payment_month
ORDER BY payment_year, payment_month;

-- 3. Weekend vs Weekday Revenue
SELECT * FROM payment;
WITH revenue_by_day AS (
SELECT 
	DAYNAME(payment_date) AS name_day,
    amount
FROM payment
)
SELECT
	IF(name_day IN ('Sunday','Saturday'),'Weekend','Weekday') AS 'day_type',
    SUM(amount) AS Revenue
FROM revenue_by_day
GROUP BY 
IF(name_day IN ('Sunday','Saturday'),'Weekend','Weekday');

-- 4. Peak Rental Weekday
SELECT * FROM rental;
SELECT
	DAYNAME(rental_date) AS day_name,
    COUNT(*) AS cnt_rental
FROM rental
GROUP BY
	DAYNAME(rental_date)
ORDER BY
	cnt_rental DESC
LIMIT 1;

-- 5. Monthly New Customer Growth
SELECT * FROM customer;
SELECT
	YEAR(create_date) AS aquisition_year,
    MONTH(create_date) AS aquisition_month,
    COUNT(*) AS aquisition
FROM customer
GROUP BY
	YEAR(create_date),
    MONTH(create_date)
ORDER BY
	YEAR(create_date),
    MONTH(create_date);

-- Alternative Solution
SELECT
	DATE_FORMAT(create_date, '%Y-%m') AS aquisition_month,
    COUNT(*) AS new_customer
FROM customer
GROUP BY aquisition_month
ORDER BY aquisition_month;

-- 6. 6. Rolling 30-Day Revenue
SELECT * FROM payment;
SELECT
	MAX(payment_date),
	DATE_SUB(MAX(payment_date), INTERVAL 30 DAY)
FROM payment;

WITH daily_revenue AS (
SELECT
	DATE(payment_date) AS payment_day,
    SUM(amount) AS daily_revenue
FROM payment
GROUP BY payment_day
ORDER BY payment_day
)
SELECT
	ROW_NUMBER() OVER() AS Sequence,
	payment_day,
    daily_revenue,    
    SUM(daily_revenue) OVER(
    ORDER BY payment_day
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30_day_revenue
FROM daily_revenue;

-- 7. Top 5 Revenue Months
SELECT * FROM payment;
SELECT
	DATE_FORMAT(payment_date, '%Y-%m') AS revenue_month,
    SUM(amount) AS revenue
FROM payment
GROUP BY 
	DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY
	revenue DESC
LIMIT 5;

-- 8. Rental Hour Distribution
SELECT * FROM rental;
SELECT
	HOUR(rental_date) AS rental_hour,
    COUNT(*) AS ttl_rental,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100,2) AS per_distribution
FROM rental
GROUP BY rental_hour
ORDER BY rental_hour;

-- 9. Monthly Active Customers
SELECT * FROM payment;
SELECT
	DATE_FORMAT(payment_date, '%Y-%m') AS customer_by_month,
	COUNT(DISTINCT(customer_id)) AS unique_customers
FROM payment
GROUP BY
	DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY
	DATE_FORMAT(payment_date, '%Y-%m');
    
-- 10. First vs Repeat Rentals
SELECT * FROM rental;
SELECT
	customer_id,
    rental_date,
    CASE WHEN 
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY rental_date) = 1 THEN 'First'
    ELSE 'Repeat'
    END AS rental_type
FROM rental;

-- 11. Average Rental Duration
SELECT * FROM rental;
SELECT
	customer_id,
    ROUND(AVG(DATEDIFF(return_date, rental_date)),0) AS avg_rental_duration
FROM rental
WHERE return_date IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;

-- 12. Average payment amount by WEEKDAY
SELECT * FROM payment;
WITH day_of_payment AS (
SELECT
	IF(
	DAYNAME(payment_date) IN ('Sunday','Saturday'),'Weekend','Weekday'
    ) AS payment_day,
    amount
FROM payment
)
SELECT
	payment_day,
    ROUND(AVG(amount),2) AS avg_payment
FROM day_of_payment
GROUP BY payment_day;

-- 13. Late Return Detection
SELECT * FROM rental;
SELECT * FROM film;
SELECT * FROM inventory;
SELECT
	r.customer_id,
    f.film_id,
    f.title,
    f.rental_duration,
    DATEDIFF(r.return_date, r.rental_date) AS actual_days,
    CASE 
    WHEN r.return_date IS NULL THEN 'Not Returned'
    WHEN DATEDIFF(r.return_date, r.rental_date) > f.rental_duration THEN 'Return Late'
    ELSE 'Return on Time'
    END AS Return_status
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
ORDER BY customer_id;

-- 14. Customer Lifetime (Active Days)
SELECT * FROM rental;
SELECT
	customer_id,
    DATEDIFF(MAX(rental_date), MIN(rental_date)) AS customer_active_days,
	MIN(rental_date) AS first_rental,
    MAX(rental_date) AS latest_rental
FROM rental
GROUP BY customer_id
ORDER BY customer_active_days DESC;

-- 15. Days to First Rental
SELECT * FROM customer;
SELECT * FROM rental;
SELECT
	c.customer_id,
    c.create_date,
    MIN(r.rental_date) AS first_rental,
    DATEDIFF(MIN(r.rental_date), c.create_date) AS onboarding_days
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- 16. Inactive Customers
SELECT * FROM rental;
WITH latest_customer_rental AS (
SELECT 
	customer_id, 
    MAX(rental_date) AS latest_rental
FROM rental
GROUP BY customer_id 
),
max_rental_cte AS (
SELECT
	MAX(rental_date) AS max_dt
    FROM rental
    )
SELECT
	lcr.customer_id,
    DATE(lcr.latest_rental) AS latest_rental,
    DATE(mrc.max_dt) AS global_rental_date,
    DATEDIFF(mrc.max_dt, lcr.latest_rental) AS Inactive_days,
    CASE WHEN
		lcr.latest_rental >=
		DATE_SUB(mrc.max_dt, INTERVAL 60 DAY) THEN 'Active Customer'
        ELSE 'Inactive Customer'
        END AS Customer_Status
FROM latest_customer_rental lcr
CROSS JOIN max_rental_cte mrc
WHERE 
	lcr.latest_rental > DATE_SUB(mrc.max_dt, INTERVAL 60 DAY)
ORDER BY 
	lcr.customer_id;
    
-- 17. Month-over-Month Growth
SELECT * FROM payment;
WITH customer_revenue AS (
SELECT
	DATE_FORMAT(payment_date, '%Y-%m') AS monthly_revenue,
    SUM(amount) AS revenue
FROM payment
GROUP BY 
DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
	monthly_revenue,
    revenue,
    LAG(revenue) OVER(ORDER BY monthly_revenue) AS prev_month_revenue,
    ROUND(
			(revenue - LAG(revenue) OVER(ORDER BY monthly_revenue))
            / LAG(revenue) OVER(ORDER BY monthly_revenue) * 100, 2) AS month_growth
FROM customer_revenue;

-- 18. Consecutive Active Months
WITH monthly_activity AS (
SELECT DISTINCT
	customer_id,
    YEAR(rental_date) AS yr,
    MONTH(rental_date) AS mnth
FROM rental
),
month_indexed AS (
SELECT 
	customer_id,
    yr,
    mnth,
    (yr*12+mnth) AS month_index
FROM monthly_activity
),
Numbered AS (
SELECT
	customer_id,
    month_index,
    ROW_NUMBER() OVER(
    PARTITION BY customer_id
    ORDER BY month_index
    ) AS rn
FROM month_indexed
),
grouped AS (
SELECT
	customer_id,
    (month_index - rn) AS grp
FROM Numbered
)
SELECT
	customer_id
FROM grouped
GROUP BY customer_id, grp
HAVING COUNT(*) >= 3;

-- Solution Practice again
SELECT * FROM rental;
WITH By_month AS (
SELECT DISTINCT
	customer_id,
    YEAR(rental_date) AS yr,
    MONTH(rental_date) AS mnth
FROM rental
),
indexation AS (
SELECT
	customer_id,
    yr,
    mnth,
    (yr*12 + mnth) AS Index_month
FROM By_month
),
customer_rn AS (
SELECT
	customer_id,
    yr,
    mnth,
    Index_month,
    ROW_NUMBER() OVER(
    PARTITION BY customer_id
    ORDER BY Index_month
    )rn
FROM indexation
),
grouped AS (
SELECT
	customer_id,
    yr,
    mnth,
    Index_month,
    (Index_month - rn) AS grp
FROM customer_rn
),
customers_with_gaps AS(
SELECT
	customer_id
FROM grouped
GROUP BY customer_id
HAVING COUNT(DISTINCT grp) >= 1
)
SELECT
	g.customer_id,
    g.grp,
    MIN(CONCAT(g.yr, '-', LPAD(g.mnth,2,'0'))) AS start_month,
    MAX(CONCAT(g.yr, '-', LPAD(g.mnth,2,'0'))) AS end_month,
    COUNT(*) AS months_in_streak
FROM grouped g
JOIN customers_with_gaps c
ON g.customer_id = c.customer_id
GROUP BY g.customer_id, g.grp
ORDER BY g.customer_id, start_month;

-- 19. Store YoY Growth
SELECT * FROM store;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM inventory;

WITH per_store_revenue AS (
SELECT
	s.store_id,
	YEAR(p.payment_date) AS payment_year,
    SUM(p.amount) AS revenue
FROM payment p
JOIN rental r 
	ON p.rental_id = r.rental_id
JOIN inventory i 
	ON r.inventory_id = i.inventory_id
JOIN store s 
	ON i.store_id = s.store_id
GROUP BY
	s.store_id,
	YEAR(p.payment_date)
),
prev_year_store_rev AS (
SELECT
	store_id,
    payment_year,
    revenue,
    LAG(revenue) OVER(
    PARTITION BY store_id 
    ORDER BY payment_year) AS previous_year_revenue
FROM per_store_revenue
)
SELECT
	store_id,
    payment_year,
    revenue,
    previous_year_revenue,
    ROUND(
    (revenue - previous_year_revenue)
    /NULLIF(previous_year_revenue, 0)*100,2) AS yoy_growth_pct
FROM prev_year_store_rev
ORDER BY store_id, payment_year;

-- 20. 30-Day Retention Rate
SELECT * FROM rental;
WITH prev_rental_table AS (
SELECT
	customer_id, 
    DATE(rental_date) AS rental_date,
    LAG(DATE(rental_date)) OVER(
    PARTITION BY customer_id
    ORDER BY rental_date) AS prev_rental_date
FROM rental
),
cus_retention_table AS (
SELECT
	customer_id,
    rental_date,
    prev_rental_date,
    DATEDIFF(rental_date, prev_rental_date) AS retention_days
FROM prev_rental_table
)
SELECT
	customer_id,
    COUNT(*) AS retention_times
FROM cus_retention_table
WHERE retention_days <= 30
GROUP BY customer_id;