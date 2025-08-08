--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 07
-- Exercise 03
--------------------------------------------------------------------------------
-- In this exercise, we will explore the range() and generate_series()
-- table functions of DuckDB a bit more. These generate series of integers
-- (or timestamps) only, but a SQL query can turn these number series into
-- anything we require.  Below, we will provide you with a few result tables
-- that you should try to reproduce using the range() and generate_series()
-- functions plus properly designed SELECT clauses.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- ┌─────────┐
-- │ letter  │
-- │ varchar │
-- ├─────────┤
-- │ a       │
-- │ d       │
-- │ g       │
-- │ j       │
-- │ m       │
-- │ p       │
-- │ s       │
-- │ v       │
-- │ y       │
-- │ b       │
-- │ e       │
-- │ h       │
-- │ k       │
-- │ n       │
-- │ q       │
-- │ t       │
-- │ w       │
-- │ z       │
-- └─────────┘
--
-- Hint: Use the ASCII value of 'a' and the modulo operator to generate
--       the letters in the alphabet. The ASCII value of 'a' is 97.
--       You can use the chr() function to convert an ASCII value to a character.
--------------------------------------------------------------------------------
-- Solution:

SELECT chr(CAST(97 + (i * 3) % 26 AS INTEGER)) AS letter
FROM generate_series(0, 17) AS t(i);

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- ┌───────┐
-- │ value │
-- │ int64 │
-- ├───────┤
-- │     0 │
-- │     1 │
-- │     0 │
-- │     3 │
-- │     0 │
-- │     5 │
-- │     0 │
-- │     7 │
-- │     0 │
-- │     9 │
-- │     0 │
-- └───────┘
--------------------------------------------------------------------------------
-- Solution:

SELECT 
CASE WHEN i % 2 = 0 THEN 0 ELSE i END AS value
FROM generate_series(0, 10) AS t(i);

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- ┌────────┐
-- │ value  │
-- │ double │
-- ├────────┤
-- │   0.01 │
-- │    0.1 │
-- │    1.0 │
-- │   10.0 │
-- │  100.0 │
-- │ 1000.0 │
-- └────────┘
--
-- Hint: Use a negative step value to generate the values in reverse order and
--       divide 1000.0 by 10 raised to the power of the generated value
--------------------------------------------------------------------------------
-- Solution:

SELECT 1000.0 / POW(10, i) AS value
FROM generate_series(5, 0, -1) AS t(i);


--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- ┌────────┐
-- │ value  │
-- │ double │
-- ├────────┤
-- │   -1.0 │
-- │    2.0 │
-- │   -3.0 │
-- │    4.0 │
-- │   -5.0 │
-- └────────┘
--------------------------------------------------------------------------------
-- Solution:

SELECT 
CASE WHEN i % 2 = 0 THEN CAST(i + 1 AS DOUBLE) ELSE CAST(-(i + 1) AS DOUBLE) END AS value
FROM generate_series(0, 4) AS t(i);


--------------------------------------------------------------------------------
-- Task (e)
--------------------------------------------------------------------------------
-- ┌──────────┐
-- │   DBMS   │
-- │ varchar  │
-- ├──────────┤
-- │ duck     │
-- │ elephant │
-- │ dolphin  │
-- │ duck     │
-- │ elephant │
-- │ dolphin  │
-- │ duck     │
-- │ elephant │
-- │ dolphin  │
-- │ duck     │
-- └──────────┘
--------------------------------------------------------------------------------
-- Solution:

SELECT 
CASE i % 3 
WHEN 0 THEN 'duck' 
WHEN 1 THEN 'elephant' 
ELSE 'dolphin' 
END AS DBMS
FROM generate_series(0, 9) AS t(i);

--------------------------------------------------------------------------------
