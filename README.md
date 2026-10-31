# 🎬 Movie Rental SQL Analysis

**Business questions answered with MySQL: joins, CTEs, window functions and rolling revenue.**

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analysis-orange)

I built this to practice SQL the way it is used at work: start with a business question, write the query, then check what the result means. I work in finance operations, so most questions are about revenue, customers and trends.

---

## 🔥 3 queries I am proud of

### 1. Rolling 7-day revenue (Q24)

Only 41 of the 267 days in the data have sales. A normal rolling sum skips the empty days, so a "7-day" number can quietly cover weeks. I fixed it with a recursive calendar, so empty days count as 0.

<img src="screenshots/result_1_rolling_7day.png" width="800" alt="Rolling 7-day revenue result">

<img src="screenshots/rolling_7day_chart.png" width="800" alt="Rolling 7-day revenue chart">

<details>
<summary>Show the query</summary>

```sql
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
```

</details>

### 2. Top 5 customers in each store (Q10)

`DENSE_RANK()` with `PARTITION BY` ranks customers inside each store, so ties are handled fairly.

<img src="screenshots/result_2_top5_per_store.png" width="800" alt="Top 5 customers per store">

<details>
<summary>Show the query</summary>

```sql
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
```

</details>

### 3. Revenue share by category (Q9)

A CTE and a subquery turn revenue into a percentage of the total.

<img src="screenshots/result_3_category_share.png" width="800" alt="Revenue share by category">

<details>
<summary>Show the query</summary>

```sql
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
```

</details>

---

## 🔎 What the data showed

- **Karl Seal** is the top customer, with 221.55 in payments.
- **Sports** is the top category (7.88% of revenue). The gap to the last one (Music, 5.07%) is small.
- **Both stores earn almost the same:** 49.68% and 50.32%.

> Payments only exist for May to August 2005 and a few days of February 2006, so I treat growth numbers as practice for the technique, not as real business trends.

---

## 🗂️ What's inside

```
sql-portfolio-movie-rental/
├── screenshots/                       # Result images
├── mavenmovies_db_schema.sql          # Creates the database and tables
├── mavenmovies_date_time_query.sql    # Date and time analysis (retention, streaks, rolling revenue)
├── mavenmovies_main_query_schema.sql  # Main business questions (Q1 to Q30)
└── README.md
```

The data is the Maven Movies database, based on the Sakila sample database.

## 🚀 Run it yourself

```bash
git clone https://github.com/Siddhartha-data76/sql-portfolio-movie-rental.git
cd sql-portfolio-movie-rental
```

Then in MySQL:

```sql
SOURCE mavenmovies_db_schema.sql;
```

Open either query file and run the queries one by one.

---

## ⭐ Like it?

If this helped you practice SQL, a star would make my day. Know a better way to solve one of the queries? Open an issue, I would love to learn from it.

Let's connect on [LinkedIn](https://www.linkedin.com/in/siddhartha-gupta-5025a9195/).
