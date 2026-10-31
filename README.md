# sql-portfolio-movie-rental
SQL analysis of a movie rental database in MySQL: joins, CTEs, window functions, rolling revenue and retention.

# 🎬 Maven Movies SQL Analysis

**Turning a movie rental database into real business answers, using only MySQL.**

Who are the best customers? Which store earns the most? Is revenue growing or slowing down? This project answers questions like these with SQL, from simple joins to window functions and recursive CTEs.

---

## 💡 Why I built this

I wanted to practice SQL the way it is used at work. Not just "write a SELECT", but start with a business question, find the right data, build the query, and explain what the result means.

I work in finance operations, so I like questions about money, trends and customer behaviour. That is why most of the queries here look at revenue, retention and growth.

---

## 🗂️ What's inside

```
maven-movies-sql-analysis/
├── mavenmovies_db_schema.sql          # Creates the database, tables and relationships
├── mavenmovies_date_time_query.sql    # Date and time analysis
├── mavenmovies_main_query_schema.sql  # Main business questions
└── README.md
```

The database is a Sakila-style movie rental business with customers, films, actors, categories, rentals, payments, inventory, stores and staff.

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
cd maven-movies-sql-analysis
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

---

## ⭐ Like it?

If this helped you practice SQL, a star on the repo would make my day. Found a better way to solve one of the queries? Open an issue or a pull request, I would love to learn from it.

Let's connect on [LinkedIn](https://www.linkedin.com/in/siddhartha-gupta-5025a9195/).
