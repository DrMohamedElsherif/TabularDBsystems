--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 06
-- Exercise 02
--------------------------------------------------------------------------------
-- We did learn about aggregation functions in the lecture and in this exercise
-- we will use them to compute some statistics on the TPC-H table `lineitem`.
-- Please use the DuckDB database file `lineitem.db` that you created in
-- Assignment 06 Exercise 01.
-- Please hand-in the SQL code that you used to compute the statistics.
-- Note: https://duckdb.org/docs/stable/sql/functions/aggregates.html
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please compute the total number of rows in the table `lineitem`.
--------------------------------------------------------------------------------
-- Solution:

SELECT COUNT(*) AS total_rows FROM lineitem;
┌────────────────┐
│   total_rows   │
│     int64      │
├────────────────┤
│    6001215     │
│ (6.00 million) │
└────────────────┘

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Please compute the total number of rows in the table `lineitem` where
-- `l_shipdate` is before '1995-06-17' and `l_returnflag` is neither 'A' nor 'R'.
--------------------------------------------------------------------------------
-- Solution:

SELECT COUNT(*) AS filtered_rows
  FROM lineitem
  WHERE l_shipdate < DATE '1995-06-17'
    AND l_returnflag NOT IN ('A', 'R');
┌───────────────┐
│ filtered_rows │
│     int64     │
├───────────────┤
│     36320     │
└───────────────┘

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Please compute the minimum, maximum, and average `l_quantity` of all rows in
-- the table `lineitem`. Use a single SQL query to compute all three statistics.
--------------------------------------------------------------------------------
-- Solution:

SELECT
    MIN(l_quantity) AS min_quantity,
    MAX(l_quantity) AS max_quantity,
    AVG(l_quantity) AS avg_quantity
  FROM lineitem;
┌──────────────┬──────────────┬────────────────────┐
│ min_quantity │ max_quantity │    avg_quantity    │
│    double    │    double    │       double       │
├──────────────┼──────────────┼────────────────────┤
│     1.0      │     50.0     │ 25.507967136654827 │
└──────────────┴──────────────┴────────────────────┘

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- Please write a single SQL query that outputs two double values
-- (between 0.0 and 100.0):
-- - the percentage of rows for which l_linestatus is 'F' as well as
-- - the percentage of rows for which l_linestatus is 'O'.
--------------------------------------------------------------------------------
-- Solution:

SELECT
    100.0 * SUM(CASE WHEN l_linestatus = 'F' THEN 1 ELSE 0 END) / COUNT(*) AS percent_F,
    100.0 * SUM(CASE WHEN l_linestatus = 'O' THEN 1 ELSE 0 END) / COUNT(*) AS percent_O
  FROM lineitem;
┌───────────────────┬───────────────────┐
│     percent_F     │     percent_O     │
│      double       │      double       │
├───────────────────┼───────────────────┤
│ 49.92683981493747 │ 50.07316018506253 │
└───────────────────┴───────────────────┘

--------------------------------------------------------------------------------
