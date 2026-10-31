# 🎬 Movie Rental SQL Analysis

**Business questions answered with MySQL: joins, CTEs, window functions and rolling revenue.**

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analysis-orange)

I built this to practice SQL the way it is used at work: start with a business question, write the query, then check what the result means. I work in finance operations, so most questions are about revenue, customers and trends.

---

## 🔥 3 queries I am proud of

### 1. Rolling 7-day revenue (Q24)

Only 41 of the 267 days in the data have sales. A normal rolling sum skips the empty days, so a "7-day" number can quietly cover weeks. I fixed it with a recursive calendar, so empty days count as 0.

<img width="449" height="356" alt="1  Rolling 7-day revenue (Q24)" src="https://github.com/user-attachments/assets/1c3dd177-8505-4027-9103-58c69023a900" />


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

<img width="562" height="274" alt="2  Top 5 customers in each store (Q10)" src="https://github.com/user-attachments/assets/1e5fd25b-4172-477f-a73d-aead249a392d" />


<details>
<summary>Show the query</summary>

```sql
WITH customer_rnk AS (
SELECT
    s.store_id,
    p.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS revenue,
    DENSE_RANK() OVER(PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS revenue_rnk
FROM payment p
JOIN staff st 
ON p.staff_id = st.staff_id
JOIN customer c
ON c.customer_id = p.customer_id
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

<img width="410" height="329" alt="3  Revenue share by category (Q9)" src="https://github.com/user-attachments/assets/6dce383e-b5f6-4454-8167-8d08cb8e0a3e" />


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

- **Rolling revenue (Q24):** the highest 7-day revenue was 19,282.62, for the week ending 2 August 2005. Sales come in bursts, with only 41 of 267 days having any payments.
- **Top customers per store (Q10):** Karl Seal is the only customer in the top 5 of both stores. He is third in each.
- **Category share (Q9):** Sports leads with 7.88% of revenue and Music is last with 5.07%. The gap is small, so no single category carries the business.

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

