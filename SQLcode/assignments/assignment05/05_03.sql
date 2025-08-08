--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 05
-- Exercise 03
--------------------------------------------------------------------------------
-- The TPC-H database benchmark operates over synthetic generated data
-- (like table lineitem we have already seen before).  The data, however,
-- is not entirely random but satisfies specific conditions (in DB
-- lingo: constraints).  One such constraint on table lineitem is:
--
--   Column l_returnflag is set to a value selected as follows:
--     If column l_receiptdate <= June 17, 1995
--     then either "R" or "A" is selected at random
--     else "N" is selected.
--
-- (Columns l_returnflag and l_receiptdate are 9th and 13th columns in
-- the lineitem table, respectively.)
--
-- The Python program constraint.py is designed to read file lineitem.csv
-- (available at https://db.cs.uni-tuebingen.de/staticfiles/lineitem.csv)
-- and check whether the TPC-H data generator has created a lineitem table
-- that satisifes the above constraint.
-- The program runs sloooow, however.  Indeed, there are A LOT of
-- details in the program that could be optimized.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Rewrite Python program constraint.y into fast-constraint.py such that
-- the new program implements a check for the above constraint and still
-- generates the expected output.  The new program, however, should run
-- at least 3 TIMES FASTER than the original constraint.py.
--------------------------------------------------------------------------------
-- Solution:
-- Please hand-in the source for program fast-constraint.py.
-- At the bottom of your program include a Python comment that gives
-- the run time for both constraint.py and fast-constraint.py when you
-- execute the programs on your computer.

-- solution at: assignment05/fast-constraint.py

-- time logs:

-- running: time python constraint.py lineitem.csv
-- > TPC-H constraint satisfied
-- real    58,03s
-- user    57,33s
-- sys     0,68s

-- running: time python fast-constraint.py lineitem.csv
-- real    2.95s
-- user    2.80s
-- sys     0.14s

-- improvement:
-- real    94,92% (19x faster)
-- user    94,10% (20x faster)
-- sys     79,41% (4x faster)

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Formulate a SQL query over file lineitem.csv that outputs the NUMBER
-- OF ROWS that violate  the above TPC-H constraint.  (If the data was
-- generated OK, the output of this query thus should be 0.)
--------------------------------------------------------------------------------
-- Solution:

SELECT COUNT(*) AS violations
FROM read_csv('lineitem.csv', delim='|', header=false)
WHERE 
    column12 <= DATE '1995-06-17' AND column08 NOT IN ('R', 'A')
    OR
    column12 > DATE '1995-06-17' AND column08 != 'N';

-- time log:
-- real    0.39s
-- user    2.90s
-- sys     0.13s
--------------------------------------------------------------------------------
