--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 02
-- Exercise 02
--------------------------------------------------------------------------------
-- DuckDB provides a very powerful CSV import functionality saving you from
-- a lot of headache when it comes to loading data from CSV files—or writing
-- data to CSV files:
-- https://duckdb.org/docs/stable/data/csv/overview
-- File `broken.csv` contains some CSV data that you want to query
-- using DuckDB. However, the file is broken and cannot be loaded directly:
FROM
    read_csv ('broken.csv');

-- ┌─────────┬─────────┬─────────┐
-- │ column0 │ column1 │ column2 │
-- │  int64  │ varchar │  int64  │
-- ├─────────┼─────────┼─────────┤
-- │    6    │ NULL    │   30    │
-- └─────────┴─────────┴─────────┘
-- Instead of six rows with columns {id, name, age}, the query returns a bogous
-- result. This can happen if the CSV file is not well-formed or if it contains
-- inconsistent data.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please fix the CSV file `broken.csv` so that it can be loaded without any issues.
--------------------------------------------------------------------------------
-- Solution:
-- See broken_fixed.CSV
--
-- (line counting 1 based)
-- -> line 1) Header, seems good
-- -> line 2) first entry, seems also good
-- -> line 3) change "thirty" to 30
-- -> line 4) remove comma behind Alice and remove leading and trailing "
-- -> line 5) remove comma behind Bob
-- -> line 6) it is recommendet to stick to one type of filling a cell:
--              if we have always (name surname) in the column "name" we want to
--              keep it like that for ALL cells in the column "name". But here we
--              only now the name "Cahrlie". Our suggestion is to maintain two columns:
--              one "name" and one "surname" column. For each individual we do not
--              know the surname or name we set it NULL (keep it empty in the csv)
--              We understand this task to stick to the {id, name, age} scheme thus
--              we just leave Charlie in the cells
-- -> line 7) change | to , and remove NULL (empty cells (i.e. ,,) is interpreted as NULL
--              by duckDB)
--
-- run:
FROM
    read_csv ('broken_fixed.csv');

--------------------------------------------------------------------------------
