USE mavenmovies;
/* 1. Top Revenue Customers
Find the customers who generated the highest total revenue. */
-- My Solution
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS revenue
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY 
	c.customer_id,
    c.first_name,
    c.last_name
ORDER BY revenue DESC
LIMIT 5;

/* 2. Most Rented Film Categories
Find which movie categories are rented the most.*/
SELECT
	c.category_id,
    c.name,
	COUNT(*) AS total_rental	
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY
	c.category_id,
	c.name
ORDER BY
	total_rental DESC
LIMIT 5;

/* 3. Average Spend Per Customer
Find average amount spent by each customer.*/
SELECT * FROM payment;
SELECT
	customer_id,
    ROUND(AVG(amount),2) AS avg_spend
FROM payment
GROUP BY customer_id;

/* 4. Customers With Above Average Spending
Find customers whose total spending is higher than overall average customer spending. */
SELECT
	customer_id,
    ttl_spend
FROM (
	SELECT
		customer_id,
        SUM(amount) AS ttl_spend
	FROM payment
    GROUP BY customer_id
) t
WHERE ttl_spend > (
SELECT 
ROUND(AVG(ttl_spend),2) AS cust_avg
FROM (
SELECT
	customer_id,
    SUM(amount) AS ttl_spend
FROM payment
GROUP BY customer_id
) avg_table
);

-- 4.1 Alternative Solution
WITH customer_spending AS (
SELECT
	customer_id,
    SUM(amount) AS ttl_spend
FROM payment
GROUP BY customer_id
)
SELECT
	customer_id,
    ttl_spend
FROM customer_spending
WHERE ttl_spend > (
SELECT
	AVG(ttl_spend)
FROM customer_spending
);

/* 5. Store-wise Revenue Contribution
Find how much revenue each store contributes to total company revenue. */
SELECT
	s.store_id,
    SUM(p.amount) AS revenue
FROM payment p
JOIN staff st ON st.staff_id = p.staff_id
JOIN store s ON s.store_id = st.store_id
GROUP BY s.store_id;

-- 5.1 Alternative solution
WITH store_revenue AS (
SELECT
	s.store_id,
    SUM(p.amount) AS revenue
FROM payment p
JOIN staff st ON st.staff_id = p.staff_id
JOIN store s ON s.store_id = st.store_id
GROUP BY s.store_id
)
SELECT
	store_id,
    revenue,
    ROUND(
    (revenue /
    (SELECT 
		SUM(revenue) 
	FROM store_revenue) * 100)
    ,2) AS store_percentage
FROM store_revenue;

/* 6. Most Frequently Rented Movies
Find movies rented highest number of times.*/
SELECT
	f.film_id,
    f.title,
    COUNT(*) AS rental_count
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY
	f.film_id,
    f.title
ORDER BY rental_count DESC;

/* 7. Customers Renting From Multiple Stores
Find customers who rented movies from more than one store */
WITH multiple_store AS (
SELECT 
	DISTINCT(c.customer_id),
    s.store_id
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
JOIN staff st ON st.staff_id = r.staff_id
JOIN store s ON s.store_id = st.store_id
)
SELECT
	customer_id,
    COUNT(store_id) AS store_count
FROM multiple_store
GROUP BY customer_id
HAVING store_count > 1
ORDER BY customer_id;

/* 8. Monthly Active Customers
Find number of unique active customers each month. */
SELECT * FROM rental;
SELECT
	DATE_FORMAT(rental_date, '%Y-%m') AS mnth_count,
    COUNT(DISTINCT(customer_id)) AS unique_customer
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m');

/* 9. Revenue Contribution by Category
Find percentage contribution of each category to total revenue. */
WITH category_revenue AS (
SELECT
	c.name,
	SUM(p.amount) AS revenue
FROM category c
JOIN film_category fc 
ON c.category_id = fc.category_id
JOIN inventory i 
ON fc.film_id = i.film_id
JOIN rental r 
ON i.inventory_id = r.inventory_id
JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY c.name
)
SELECT
	name,
    revenue,
    ROUND(
    (revenue/
    (SELECT 
		SUM(revenue)
        FROM category_revenue)
        * 100)
        ,2) AS category_per
	FROM category_revenue
    ORDER BY category_per DESC;
    
/* 10. Top 5 Customers Per Store
Find top 5 revenue-generating customers within each store. */
WITH customer_rnk AS (
SELECT
	s.store_id,
	p.customer_id,
    SUM(p.amount) AS revenue,
    DENSE_RANK() OVER(PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS revenue_rnk
FROM payment p
JOIN staff st 
ON p.staff_id = st.staff_id
JOIN store s ON
s.store_id = st.store_id
GROUP BY p.customer_id, s.store_id
)
SELECT * FROM customer_rnk
WHERE revenue_rnk <= 5
ORDER BY store_id, revenue DESC;
				
/* 11. Customers Who Never Rented
Find customers who never made any rental.*/
SELECT
	c.customer_id,
    COUNT(r.rental_id) AS rental_by_cus
FROM customer c
LEFT JOIN rental r 
ON r.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) = 0;

/* 12. Films Never Rented
Find movies that were never rented.*/
SELECT
	f.film_id,
    f.title,
    COUNT(r.rental_id) AS cnt_films
FROM film f
LEFT JOIN inventory i 
ON f.film_id = i.film_id
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) = 0;

/* 13. Customers Renting More Than Average Number of Movies
Find customers whose rental count exceeds average rental count. */
SELECT * FROM rental;
WITH rental_cnt AS (
SELECT 
	customer_id,
    COUNT(*) AS cnt_rent
FROM rental
GROUP BY customer_id
),
avg_rental AS (
SELECT
	ROUND(
	AVG(cnt_rent),0) AS rental_avg
FROM rental_cnt
)
SELECT
	customer_id,
    cnt_rent
FROM rental_cnt
WHERE cnt_rent > 
(SELECT 
	rental_avg
FROM avg_rental
)
ORDER BY cnt_rent DESC;

/* 14. Most Valuable Customer Per City
Find highest revenue-generating customer in each city.*/
WITH city_rev AS (
SELECT
	cu.customer_id,
    c.city,
    SUM(p.amount) AS revenue
FROM customer cu
JOIN address a ON a.address_id = cu.address_id
JOIN city c ON c.city_id = a.city_id
JOIN payment p ON p.customer_id = cu.customer_id
GROUP BY c.city, cu.customer_id
),
city_rnk AS (
SELECT
	customer_id,
    city,
    revenue,
    ROW_NUMBER() OVER(PARTITION BY city ORDER BY revenue DESC) AS rnk
FROM city_rev
)
SELECT * FROM city_rnk
WHERE rnk = 1;

/* 15. Customers Who Rented Same Film Multiple Times
Find customers who rented the same movie repeatedly. */
SELECT
	r.customer_id,
	f.film_id,
    f.title,
    COUNT(*) AS times_rented
FROM rental r
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY r.customer_id, f.film_id, f.title
HAVING COUNT(*) > 1
ORDER BY r.customer_id;

/* 16. Revenue Difference Between Stores
Find difference in revenue generated between stores. */
WITH store_rev AS (
SELECT
	s.store_id,
    SUM(p.amount) AS revenue
FROM payment p
JOIN staff st ON p.staff_id = st.staff_id
JOIN store s ON s.store_id = st.store_id
GROUP BY s.store_id
)
SELECT
	store_id,
    revenue,
    (revenue -
    LAG(revenue) OVER(ORDER BY store_id))
FROM store_rev;

/*17. Actors Appearing in Most Films
Find actors who acted in highest number of films.*/
WITH multiple_films AS (
SELECT
	fa.actor_id,
    a.first_name,
    a.last_name,
    COUNT(*) AS no_of_films
FROM film_actor fa
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id, a.first_name, a.last_name
)
SELECT
	actor_id,
    first_name,
    last_name,
    no_of_films,
    DENSE_RANK() OVER(ORDER BY no_of_films DESC) AS actor_rnk
FROM multiple_films;

/* 18. Customers Spending Consistently Every Month
Find customers who made payments every single month available in dataset.*/
SELECT
	customer_id
FROM payment
GROUP BY customer_id
HAVING COUNT(DISTINCT DATE_FORMAT(payment_date, '%Y-%m')) =
(SELECT
	COUNT(DISTINCT DATE_FORMAT(payment_date, '%Y-%m'))
    FROM payment
    );
    
/*19. Highest Revenue Film Per Category
Find highest revenue-generating movie in each category.*/
WITH category_rev AS (
SELECT
	c.name,
    f.title,
    SUM(p.amount) AS revenue,
    DENSE_RANK() OVER(PARTITION BY c.name ORDER BY SUM(p.amount) DESC) AS rnk
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY f.title, c.name
)
SELECT * FROM category_rev
WHERE rnk = 1;

/* 20. Customers Whose Spending Increased Over Time
Find customers whose monthly spending continuously increased.*/
SELECT * FROM payment;
WITH cust_rev_over_time AS (
SELECT
	customer_id,
    DATE_FORMAT(payment_date, '%Y-%m') AS time_period,
    SUM(amount) AS revenue
FROM payment
GROUP BY customer_id, DATE_FORMAT(payment_date, '%Y-%m')
),
cus_past_rev AS (
SELECT
	customer_id,
    time_period,
    revenue,
    LAG(revenue) OVER(PARTITION BY customer_id ORDER BY time_period) AS past_rev
FROM cust_rev_over_time
),
qualify_cust AS (
SELECT
	customer_id
FROM cus_past_rev
GROUP BY customer_id
HAVING SUM(
CASE 
		WHEN past_rev IS NOT NULL
        AND revenue<= past_rev
	THEN 1
    ELSE 0
END
) = 0
)
SELECT
	cp.customer_id,
    cp.time_period,
    cp.revenue,
    cp.past_rev
FROM cus_past_rev cp
JOIN qualify_cust qc ON cp.customer_id = qc.customer_id;

/* 21. Rank Customers By Revenue
Assign revenue rank to customers.*/
WITH cus_revenue AS ( 
SELECT
	customer_id,
    SUM(amount) AS revenue
FROM payment
GROUP BY customer_id
)
SELECT
	customer_id,
    revenue,
    DENSE_RANK() OVER(ORDER BY revenue DESC) AS rnk
FROM cus_revenue;

/* 22. Dense Rank Films By Rental Count
Rank movies by rentals without skipping ranks.*/
WITH rental_film AS (
SELECT 
	f.title,
    COUNT(*) AS film_cnt
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
)
SELECT
	title, 
    film_cnt,
    DENSE_RANK() OVER(ORDER BY film_cnt DESC) AS rnk
FROM rental_film;

/*Running Revenue Total
Show cumulative revenue growth over time.*/
WITH time_revenue AS (
SELECT
	DATE_FORMAT(payment_date, '%Y-%m') AS mnth_revenue,
	SUM(amount) AS revenue
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
	mnth_revenue,
    revenue,
    SUM(revenue) OVER(ORDER BY mnth_revenue) AS rolling_rev
FROM time_revenue;

/* 24. Rolling 7-Day Revenue
Calculate rolling 7-day revenue trend.*/
WITH RECURSIVE daily_revenue AS (
SELECT
	DATE(payment_date) AS payment_day,
    SUM(amount) AS revenue
FROM payment
GROUP BY DATE(payment_date)
),
calendar AS (
SELECT
	MIN(payment_day) AS dt
FROM daily_revenue

UNION ALL

SELECT
	DATE_ADD(dt, INTERVAL 1 DAY)
FROM calendar
WHERE
	dt < (
    SELECT MAX(payment_day)
    FROM daily_revenue
    )
)
SELECT
	c.dt AS payment_day,
    COALESCE(d.revenue, 0) AS daily_revenue,
    SUM(COALESCE(d.revenue, 0)) OVER(ORDER BY c.dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 7_day_rolling_rev
FROM calendar c
LEFT JOIN daily_revenue d ON c.dt = d.payment_day
ORDER BY c.dt;

/* 25. Top 3 Films Per Category
Find top-performing movies within each category.*/
WITH cnt_of_films AS (
SELECT
	f.film_id,
    f.title AS film_title,
    c.name AS category_name,
    COUNT(rental_id) AS cnt_film
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY f.film_id, f.title,c.name
),
rnk_of_films AS (
SELECT
	category_name,
    film_title,
    cnt_film,
    ROW_NUMBER() OVER(PARTITION BY category_name ORDER BY cnt_film DESC) AS rnk_per_category
FROM cnt_of_films
)
SELECT * FROM rnk_of_films
WHERE rnk_per_category <= 3;

/* 26. Revenue Difference From Previous Month
Calculate month-over-month revenue difference. */
WITH monthly_rev AS (
SELECT
	DATE_FORMAT(payment_date, "%Y-%m") AS period,
    SUM(amount) AS revenue
FROM payment
GROUP BY DATE_FORMAT(payment_date, "%Y-%m")
),
previous_mnth_rev AS (
SELECT
	period,
    revenue,
    LAG(revenue) OVER(ORDER BY period) AS pre_mnth_rev
FROM monthly_rev
)
SELECT
	period,
    revenue,
    pre_mnth_rev,
    (revenue - pre_mnth_rev) AS difference
FROM previous_mnth_rev;

/* 27. Consecutive Rental Streaks
Find customers with longest consecutive rental streak.*/
WITH customer_rental AS (
SELECT
	customer_id,
    DATE(rental_date) AS rental_day
FROM rental
GROUP BY customer_id,DATE(rental_date)
),
previous_day AS (
SELECT
	customer_id, 
    rental_day,
    LAG(rental_day) OVER(PARTITION BY customer_id ORDER BY rental_day) AS prev_day
FROM customer_rental
),
streak_start AS (
SELECT
	customer_id,
    rental_day,
    prev_day,
    CASE 
		WHEN prev_day IS NULL
        OR
        DATEDIFF(rental_day, prev_day) > 1
		THEN 1
		ELSE 0
    END AS new_streak
FROM previous_day
),
streaked_group AS (
SELECT
	customer_id,
    rental_day,
    SUM(new_streak) OVER(PARTITION BY customer_id ORDER BY rental_day) AS streak_id
FROM streak_start
),
streak_length AS (
SELECT
	customer_id,
    streak_id,
    COUNT(*) AS streak_length
FROM streaked_group
GROUP BY customer_id, streak_id
)
SELECT
	customer_id,
    MAX(streak_length) AS longest_streak
FROM streak_length
GROUP BY customer_id
ORDER BY longest_streak DESC;

/* 28. Store Revenue Running Contribution
Track cumulative contribution of stores toward total revenue.*/
WITH store_revenue AS (
SELECT
	s.store_id,
    SUM(p.amount) AS revenue
FROM payment p
JOIN rental r ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN store s ON s.store_id = i.store_id
GROUP BY s.store_id
),
store_ttl_rev AS (
SELECT
	store_id,
    revenue,
    SUM(revenue) OVER() AS total_rev
FROM store_revenue
),
store_rev_share AS (
SELECT
	store_id,
    revenue,
    ROUND(
    ((revenue/total_rev)*100),2) AS revenue_share
FROM store_ttl_rev
)
SELECT
	store_id,
    revenue,
    revenue_share,
    SUM(revenue_share) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_share
FROM store_rev_share;

/*30. Identify Revenue Outlier Customers
Find customers whose spending is abnormally high compared to others.*/
WITH cust_spend AS (
SELECT
	customer_id,
    SUM(amount) AS revenue
FROM payment
GROUP BY customer_id
),
total_revenue AS (
SELECT
	customer_id,
    revenue
FROM cust_spend
),
cust_avg_spend AS (
SELECT
	customer_id,
    revenue,
    ROUND(
    AVG(revenue) OVER(),2) AS avg_spend
FROM total_revenue
),
cust_doub_avg AS (
SELECT
	customer_id,
    revenue,
    (avg_spend * 2) AS double_of_avg
FROM cust_avg_spend
),
outlier_cust AS (
SELECT
	customer_id,
    revenue,
    (revenue - double_of_avg) AS outliers
FROM cust_doub_avg
)
SELECT * FROM outlier_cust
WHERE outliers > 0;


