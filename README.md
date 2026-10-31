# 🎬 Maven Movies SQL Analysis

**Turning a movie rental database into real business answers, using only MySQL.**

Who are the best customers? Which store earns the most? Is revenue growing or slowing down? This project answers questions like these with SQL, from simple joins to window functions and recursive CTEs.

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analysis-orange)
![Level](https://img.shields.io/badge/Level-Beginner%20to%20Advanced-green)

---

## 💡 Why I built this

I wanted to practice SQL the way it is used at work. Not just "write a SELECT", but start with a business question, find the right data, build the query, and explain what the result means.

I work in finance operations, so I like questions about money, trends and customer behaviour. That is why most of the queries here look at revenue, retention and growth.

---

## 🗂️ What's inside

```
sql-portfolio-movie-rental/
├── screenshots/                       # Result images used in this README
├── mavenmovies_db_schema.sql          # Creates the database, tables and relationships
├── mavenmovies_date_time_query.sql    # Date and time analysis
├── mavenmovies_main_query_schema.sql  # Main business questions
└── README.md
```

The data comes from the Maven Movies database, which is based on the Sakila sample database. It is a movie rental business with customers, films, actors, categories, rentals, payments, inventory, stores and staff.

---

## ❓ Business questions I answered

| Area | Question |
|---|---|
| Customers | Who are the highest-revenue customers? |
| Customers | Who spends much more than average? |
| Customers | Who keeps renting the same movie again and again? |
| Customers | Who has gone quiet, and who keeps coming back? |
| Categories | Which categories are rented the most? |
| Movies | What are the top movies inside each category? |
| Stores | How much revenue does each store bring in? |
| Stores | Who are the top 5 customers in each store? |
| Time | How does revenue change month over month and year over year? |
| Time | Which weekday and which hour are the busiest? |
| Time | What does the rolling 7-day and 30-day revenue look like? |
| Retention | Who is active in consecutive months? |

---

## 📸 Results preview

Every screenshot below is the real output of the query shown, run on the Maven Movies database.

**Who are the best customers?**

![Top 5 customers by revenue](screenshots/01_top_customers_by_revenue.png)

**Which categories bring in the most money?**

![Revenue share by category](screenshots/02_revenue_share_by_category.png)

**Who are the top customers inside each store?**

![Top 5 customers per store](screenshots/03_top5_customers_per_store.png)

**What does revenue look like over time, without gaps?**

![Rolling 7-day revenue table](screenshots/04_rolling_7day_revenue.png)

![Rolling 7-day revenue chart](screenshots/07_rolling_7day_chart.png)

**Which films lead each category?**

![Top 3 films per category](screenshots/05_top3_films_per_category.png)

**Who stays active month after month?**

![Consecutive active months](screenshots/06_consecutive_active_months.png)

---

## 🔎 What the data showed

- **Karl Seal (customer 526) is the top customer overall**, with 221.55 in payments.
- **Sports is the top category** with 7.88% of revenue. Music is last with 5.07%. The gap is small, so no category carries the business.
- **Both stores earn almost the same:** 49.68% and 50.32% of revenue.
- **Sales come in bursts.** The calendar has 267 days, but only 41 have payments. Without the calendar CTE, a "7-day" figure would stretch across weeks.

> **A note on the data:** payments only exist for May to August 2005 and a few days of February 2006. Because of that, month-over-month and year-over-year numbers can look dramatic (for example, February 2006 compared with August 2005). I treat them as practice for the technique, not as real business trends.

---

## 🔥 Featured query: rolling 7-day revenue

Some days have no sales at all. If you skip those days, a "7-day" average is wrong because it quietly covers more than 7 days.

My fix:

1. Add up payments for each day.
2. Build a full calendar of dates with a recursive CTE.
3. Join the calendar to the daily revenue.
4. Turn missing days into zero.
5. Sum the current day and the 6 days before it.

```sql
SUM(COALESCE(d.revenue, 0)) OVER (
    ORDER BY c.dt
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS rolling_7_day_revenue
```

Now every number really covers 7 days, even in quiet weeks.

---

## 🧠 SQL skills used

- **Basics:** SELECT, WHERE, DISTINCT, ORDER BY, LIMIT
- **Aggregation:** COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
- **Joins:** INNER JOIN, LEFT JOIN, multi-table joins
- **Subqueries and CTEs:** scalar subqueries, derived tables, multiple and recursive CTEs
- **Window functions:** ROW_NUMBER, DENSE_RANK, LAG, LEAD, SUM() OVER with window frames
- **Date and time:** DATE, YEAR, MONTH, MONTHNAME, DAYNAME, WEEKDAY, HOUR, DATE_FORMAT, DATEDIFF, DATE_SUB, TIMESTAMPDIFF
- **Analysis ideas:** running totals, rolling revenue, growth, retention, streaks, outliers

---

## 🚀 Run it yourself

```bash
git clone https://github.com/Siddhartha-data76/sql-portfolio-movie-rental.git
cd sql-portfolio-movie-rental
```

Then in MySQL:

```sql
SOURCE mavenmovies_db_schema.sql;
```

After that, open `mavenmovies_date_time_query.sql` or `mavenmovies_main_query_schema.sql` and run the queries one by one. Each query has a business question above it, so you can try to solve it first and compare with mine.

---

## 📚 What I learned

- Turning a vague business question into a clear SQL plan
- Keeping long queries readable with CTEs
- Using window functions for ranking, trends and comparisons
- Handling missing dates so time-based numbers stay honest
- Thinking about what the result means, not just whether the query runs

---

## 🔭 What's next

I am moving into data analytics and building my skills in **Advanced Excel, Power BI and Python**. More projects will be added here as I go.

---

## ⭐ Like it?

If this helped you practice SQL, a star on the repo would make my day. Found a better way to solve one of the queries? Open an issue or a pull request, I would love to learn from it.

Let's connect on [LinkedIn](https://www.linkedin.com/in/siddhartha-gupta-5025a9195/).
