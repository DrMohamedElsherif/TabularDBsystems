--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 06
-- Exercise 01
--------------------------------------------------------------------------------
-- In this exercise, we will explore DuckDB database files a bit.
--
-- Please download the TPC-H table `lineitem` from the following URL:
-- https://db.cs.uni-tuebingen.de/staticfiles/lineitem.csv
-- You propably already have this file from the previous assignments.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- i. Please create a DuckDB database file `lineitem.db` that only contains the
-- TPC-H table `lineitem`. Hand-in the SQL code that you used to create the
-- database file.
-- Note: You may want to use the following snippet in your SQL statement:
-- read_csv('lineitem.csv',
--           header = false,
--           names = ['l_orderkey', 'l_partkey', 'l_suppkey', 'l_linenumber', 'l_quantity',
--                    'l_extendedprice', 'l_discount', 'l_tax', 'l_returnflag',
--                    'l_linestatus', 'l_shipdate', 'l_commitdate', 'l_receiptdate',
--                    'l_shipinstruct', 'l_shipmode', 'l_comment'])
-- Otherwise, your table will not have the correct column names.
-- Note: Do not add this file to your git repository, as it is too large.
--
-- ii. Files `lineitem.csv` and `lineitem.db` are vastly different in size.
--    Why is that? Please try to come up with a brief explanation.
--------------------------------------------------------------------------------
-- Solution:

--i.
-- Create the database 
CREATE TABLE lineitem AS
SELECT *
FROM read_csv(
    'lineitem.csv',
    header = false,
    names = ['l_orderkey', 'l_partkey', 'l_suppkey', 'l_linenumber', 'l_quantity',
             'l_extendedprice', 'l_discount', 'l_tax', 'l_returnflag',
             'l_linestatus', 'l_shipdate', 'l_commitdate', 'l_receiptdate',
             'l_shipinstruct', 'l_shipmode', 'l_comment']
);

--ii.
-- The lineitem.csv file is a row-based, plain-text format where data is stored redundantly (e.g., repeated strings, numbers as text). In contrast, 
-- lineitem.db uses a binary, columnar storage format which compresses data (e.g., via dictionary encoding, run-length encoding), 
-- stores numbers in compact binary form, and avoids metadata repetition. Columnar storage also allows efficient compression of similar values within each column,
-- That's why the .db file is significantly smaller in size than the .csv file despite containing the same data.

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Please run the following SQL query while connected to the DuckDB database
-- `lineitem.db` that you created in Task (a).
-- For this task, use .timer on in DuckDB's CLI to measure the execution
-- time of the queries.
-- 1.
SELECT count(*)
FROM read_csv('lineitem.csv',
              header = false,
              names = ['l_orderkey', 'l_partkey', 'l_suppkey', 'l_linenumber', 'l_quantity',
                       'l_extendedprice', 'l_discount', 'l_tax', 'l_returnflag',
                       'l_linestatus', 'l_shipdate', 'l_commitdate', 'l_receiptdate',
                       'l_shipinstruct', 'l_shipmode', 'l_comment'])
WHERE (l_receiptdate <= '1995-06-17' AND l_returnflag <> 'A' AND l_returnflag <> 'R')
OR    (l_receiptdate > '1995-06-17'  AND l_returnflag <> 'N');

-- 2.
SELECT count(*)
FROM lineitem
WHERE (l_receiptdate <= '1995-06-17' AND l_returnflag <> 'A' AND l_returnflag <> 'R')
OR    (l_receiptdate > '1995-06-17'  AND l_returnflag <> 'N');

-- Both queries should return the same result, but they show different
-- performance characteristics. We want to investigate where the time is spent
-- in the two queries.
--
-- i. Please run the SQL queries above and report the execution time of
--    both queries.
-- ii. Please run the queries again, but this time with the `EXPLAIN ANALYZE`
--     prefix. For the first query, the output should be similar to:
-- ┌───────────────────────────┐
-- │           QUERY           │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │      EXPLAIN_ANALYZE      │
-- │    ────────────────────   │
-- │           0 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │    UNGROUPED_AGGREGATE    │
-- │    ────────────────────   │
-- │        Aggregates:        │
-- │        count_star()       │
-- │                           │
-- │           1 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │           FILTER          │
-- │    ────────────────────   │
-- │  (((l_receiptdate > '1995 │
-- │    -06-17'::DATE) AND     │
-- │ (l_returnflag != 'N')) OR │
-- │  ((l_receiptdate <= '1995 │
-- │    -06-17'::DATE) AND     │
-- │ (l_returnflag != 'A') AND │
-- │  (l_returnflag != 'R')))  │
-- │                           │
-- │           0 Rows          │
-- │          (0.08s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │         TABLE_SCAN        │
-- │    ────────────────────   │
-- │     Function: READ_CSV    │
-- │                           │
-- │        Projections:       │
-- │       l_receiptdate       │
-- │        l_returnflag       │
-- │                           │
-- │        6001215 Rows       │
-- │          (3.75s)          │
-- └───────────────────────────┘

-- Please hand-in the output for the both queries.
-- iii. Please explain the performance difference between the two queries
--     based on the output of the `EXPLAIN ANALYZE` command.
--     What is the reason for the performance difference?
--------------------------------------------------------------------------------
-- Solution:

-- i.
-- Run Time (s) 1st query: real 0.716 user 4.238517 sys 0.131741
-- Run Time (s) 2nd query: real 0.028 user 0.180941 sys 0.001689

--ii. EXECUTION PLAN FOR THE 1st QUERY
┌───────────────────────────┐
│           QUERY           │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│      EXPLAIN_ANALYZE      │
│    ────────────────────   │
│           0 Rows          │
│          (0.00s)          │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│    UNGROUPED_AGGREGATE    │
│    ────────────────────   │
│        Aggregates:        │
│        count_star()       │
│                           │
│           1 Rows          │
│          (0.00s)          │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│           FILTER          │
│    ────────────────────   │
│  (((l_receiptdate > '1995 │
│    -06-17'::DATE) AND     │
│ (l_returnflag != 'N')) OR │
│  ((l_receiptdate <= '1995 │
│    -06-17'::DATE) AND     │
│ (l_returnflag != 'A') AND │
│  (l_returnflag != 'R')))  │
│                           │
│           0 Rows          │
│          (0.09s)          │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│         TABLE_SCAN        │
│    ────────────────────   │
│     Function: READ_CSV    │
│                           │
│        Projections:       │
│       l_receiptdate       │
│        l_returnflag       │
│                           │
│        6001215 Rows       │
│          (4.39s)          │
└───────────────────────────┘
-- Run Time (s): real 0.733 user 4.366826 sys 0.128207

-- EXECUTION PLAN FOR THE 2nd QUERY

┌───────────────────────────┐
│           QUERY           │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│      EXPLAIN_ANALYZE      │
│    ────────────────────   │
│           0 Rows          │
│          (0.00s)          │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│    UNGROUPED_AGGREGATE    │
│    ────────────────────   │
│        Aggregates:        │
│        count_star()       │
│                           │
│           1 Rows          │
│          (0.00s)          │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│           FILTER          │
│    ────────────────────   │
│  (((l_receiptdate > '1995 │
│    -06-17'::DATE) AND     │
│ (l_returnflag != 'N')) OR │
│  ((l_receiptdate <= '1995 │
│    -06-17'::DATE) AND     │
│ (l_returnflag != 'A') AND │
│  (l_returnflag != 'R')))  │
│                           │
│           0 Rows          │
│          (0.16s)          │
└─────────────┬─────────────┘
┌─────────────┴─────────────┐
│         TABLE_SCAN        │
│    ────────────────────   │
│      Table: lineitem      │
│   Type: Sequential Scan   │
│                           │
│        Projections:       │
│       l_receiptdate       │
│        l_returnflag       │
│                           │
│        6001215 Rows       │
│          (0.02s)          │
└───────────────────────────┘
-- Run Time (s): real 0.032 user 0.199860 sys 0.002004

-- iii.

-- The significant performance difference between these two queries is becuase when querying the CSV directly, DuckDB must perform a full scan of the text file, 
-- parsing each of the 6 million rows and all 16 columns from scratch for every query execution. This raw parsing operation alone consumes 4.39 seconds, as shown in 
-- the EXPLAIN ANALYZE output, because the system must interpret string data, convert it to appropriate types (like dates & decimals), and handle the entire dataset
-- without any optimization. The CSV reader cannot skip any data - it must process every column and row regardless of what the query actually needs.

-- In contrast, the DuckDB table query stores the data in its native binary format, DuckDB eliminates the need for repeated parsing - the data remains in an 
-- efficiently readable form between queries. The columnar organization allows the system to read only the two relevant columns (l_receiptdate and l_returnflag) 
-- through projection pushdown, avoiding unnecessary I/O for the other 14 columns. Additionally, DuckDB applies compression techniques to the stored data, 
-- further reducing the physical amount of data that needs to be read from disk. These optimizations combine to reduce the table scan time from 4.39 seconds to 
-- just 0.02 seconds.

-- The filter operation however shows an interesting counterpoint - it actually takes slightly longer (0.16s vs 0.09s) in the DuckDB version. This likely occurs 
-- because DuckDB applies filters after decompressing the columnar data, while the CSV parser can check conditions during the initial text parsing phase. 
-- However, this minor difference is overwhelmingly offset by the massive savings in data scanning time, as we see that the overall query speed improves by 25x just
-- because the expensive parsing and full-data-scan penalties of CSV processing are completely avoided in the DuckDB table approach. 


--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Did we really save time by creating the DuckDB table `lineitem` in Task (b),
-- or could we always just use the CSV file directly?
-- Please briefly explain your answer.
--------------------------------------------------------------------------------
-- Solution:

-- As somehow explained in our answer to Task b (iii), Yes, creating the DuckDB table definitely still saves time. In summary, creating the DuckDB table saves time 
-- for all subsequent queries. While importing the CSV incurs a one-time cost, each query thereafter avoids: (1) text parsing, (2) full-column reads, and 
-- (3) dynamic type inference. Compression further reduce I/O and CPU usage, therefore creating the DuckDB table is still ideal especially for repeated queries.

--------------------------------------------------------------------------------
