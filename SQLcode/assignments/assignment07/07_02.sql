--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 07
-- Exercise 02
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- In this exercise, we will try to explore the effect of compression
-- on the query performance of DuckDB.
--
-- Please create a database compressed.db with TPC-H data at scale factor
-- sf = 10. Note: This experiment requires about 15 GB of disk space.
-- You can use the following commands to create the database
-- and the table:
ATTACH 'exclude/compressed.db';
LOAD tpch;
USE compressed;
CALL dbgen(sf = 10);

-- Restart DuckDB to clear the memory cache.

-- Then, run the following query 3 times and report the execution times
-- (use .timer on in DuckDB's CLI to measure the execution time of the query):

-- TPC-H Query 6
select
        sum(l_extendedprice * l_discount) as revenue
from
        lineitem
where
        l_shipdate >= date '1994-01-01'
        and l_shipdate < date '1994-01-01' + interval '1' year
        and l_discount between 0.06 - 0.01 and 0.06 + 0.01
        and l_quantity < 24
;

-- run1: Run Time (s): real 0.098 user 0.674917 sys 0.304693
-- run2: Run Time (s): real 0.069 user 0.711293 sys 0.024305
-- run3: Run Time (s): real 0.070 user 0.711498 sys 0.025490

-- Now, repeat the same query sequence on the uncompressed version of the
-- TPC-H data. You can use the following commands to create the uncompressed
-- database and the table:
ATTACH 'exclude/uncompressed.db';
USE uncompressed;
PRAGMA force_compression = 'Uncompressed';
COPY FROM DATABASE compressed TO uncompressed;

-- Restart DuckDB to clear the memory cache.

-- Then, run the same query 3 times and report the execution times.

-- run1: Run Time (s): real 0.158 user 0.591299 sys 1.105342
-- run2: Run Time (s): real 0.055 user 0.558520 sys 0.010524
-- run3: Run Time (s): real 0.058 user 0.561332 sys 0.020582


--
-- i. Can you explain the differences in execution times between the
--    first and the subsequent two runs of the query? (Here, it suffices to
--    focus on either the compressed or uncompressed database.)
-- ii. Now compare the performance of the first query runs in the compressed
--     and uncompressed database. Try to explain the execution time difference.
--     Do the same for the second (and third) query runs. How do you explain
--     the execution time differences now?
-- iii. Assuming that the overall query execution time is slightly worse
--      for the compressed database, would you still prefer the compressed
--      version over the uncompressed version? Why or why not?
--------------------------------------------------------------------------------
-- Solution:

-- runtime on compressed.db:
-- run1: Run Time (s): real 0.098 user 0.674917 sys 0.304693
-- run2: Run Time (s): real 0.069 user 0.711293 sys 0.024305
-- run3: Run Time (s): real 0.070 user 0.711498 sys 0.025490

-- runtime on decompressed.db:
-- run1: Run Time (s): real 0.158 user 0.591299 sys 1.105342
-- run2: Run Time (s): real 0.055 user 0.558520 sys 0.010524
-- run3: Run Time (s): real 0.058 user 0.561332 sys 0.020582

---------------------

-- i.)
-- My guess is, that the shorter execution times (especially for the sys time) is due to caching effects:
-- In the first run (real 0.098), DuckDB has to read the required data from disk and parse/decode 
-- it into memory for query execution. This involves I/O overhead decompressing column data (at least for the compressed database).
-- When executing the query again, the relevant data blocks are already cached in memory, 
-- so DuckDB no longer needs to perform disk I/O or decompression for those blocks


-- ii.)
-- First Query Run (Cold Cache):
-- -> Compressed DB:   real 0.098s
-- -> Uncompressed DB: real 0.158s

-- In the first run, the compressed database performs significantly faster. 
-- This is because compressed data occupies less space on disk, results in fewer reading times 
-- simply because there is less to read. 
-- Although decompression adds CPU overhead, this is outweighed by the savings from reduced disk reads. 
-- In contrast, the uncompressed version must load more raw data from disk into memory, leading to a higher wall-clock time.



-- Second and Third Query Runs (Warm Cache):
-- -> Compressed DB:   ~0.070s
-- -> Uncompressed DB: ~0.056s

-- After the data is cached in memory, the uncompressed database becomes slightly faster. 
-- This is because it avoids decompression entirely and can operate directly on in-memory raw data. 
-- Since the compressed data resides as compressed in the memory it has to decompress the columnar data structures,
-- which introduces minor CPU overhead.



-- iii.)

-- The key reason is storage efficiency:
-- compression significantly reduces the disk footprint (especially at scale factors like sf=10), 
-- resulting in faster cold-cache performance, and better utilization of memory bandwidth when working with large datasets. 
-- The tradeoff to increased CPU-overhead is usually worth because it enables handling larger datasets in limited memory
-- and reduces cache misses. 
-- Especiallies for queries which run over huge data or are executed in cold-cache environments.
-- Unless absolute best in-memory performance is required repeatedly, 
-- compressed storage is typically the more practical and scalable choice.
-- This said, there is a point at which the datasize get so big that it is worth to keep the data compressed.
-- that point could be found by taking different increasing sf- values (like 1, 2, 3, ..., 20) and plot them
-- against the execution times for both, compressed and decompressed databases.


--------------------------------------------------------------------------------
