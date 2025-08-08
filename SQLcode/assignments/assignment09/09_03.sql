--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 09
-- Exercise 03
--------------------------------------------------------------------------------
-- In this exercise, we will explore SQL join variants and their equivalent
-- expressions without using the JOIN keyword.
--
-- SQL features the SEMI JOIN, ANTI JOIN, and LEFT OUTER JOIN variants
-- of the join operation. These are convenient, but not strictly needed:
-- all three join variants can be equivalently expressed using SQL
-- queries that do not use the JOIN keyword at all. Let's show this.
--
-- Assume two tables S and T featuring disjoint column names.
-- Join predicate p refers to columns in both tables.
--
-- For each of the three join variants, formulate an equivalent SQL query
-- that does not use the JOIN keyword. You may use CTEs and the bag
-- operations, however.
--------------------------------------------------------------------------------
-- Task (a) — [E]
--------------------------------------------------------------------------------
-- Formulate an equivalent SQL query without using the JOIN keyword for:
-- FROM S SEMI JOIN T ON (p);
--------------------------------------------------------------------------------
-- Solution:

SELECT *
FROM S
WHERE EXISTS (
    SELECT 1
    FROM T
    WHERE p  
);

--------------------------------------------------------------------------------
-- Task (b) — [E]
--------------------------------------------------------------------------------
-- Formulate an equivalent SQL query without using the JOIN keyword for:
-- FROM S ANTI JOIN T ON (p);
--------------------------------------------------------------------------------
-- Solution:

SELECT *
FROM S
WHERE NOT EXISTS (
    SELECT 1
    FROM T
    WHERE p  
);

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Formulate an equivalent SQL query without using the JOIN keyword for:
-- FROM S LEFT OUTER JOIN T ON (p);
--
-- Hint: The UNION [ALL] BY NAME variant of the bag operation can be useful.
-- See https://duckdb.org/docs/stable/sql/query_syntax/setops#union-all-by-name
--------------------------------------------------------------------------------
-- Solution:

WITH matched AS (
    SELECT *
    FROM S, T
    WHERE p
),
unmatched AS (
    SELECT *
    FROM S
    WHERE NOT EXISTS (
        SELECT 1
        FROM T
        WHERE p
    )
)
SELECT *
FROM matched
UNION ALL BY NAME
SELECT
    unmatched.*,
    NULL AS <T_column_1>,
    NULL AS <T_column_2>,
FROM unmatched;

--------------------------------------------------------------------------------
