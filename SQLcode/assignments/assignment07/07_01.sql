--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 07
-- Exercise 01
--------------------------------------------------------------------------------
-- In this exercise, we will explore the columnar table storage format of DuckDB.
--
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- In the last assignment, we created a table lineitem from the TPC-H
-- benchmark data. We saw that the storage size of this table
-- shrunk from about 720 MB to about 160 MB when we used the
-- default compression scheme of DuckDB.
--
-- Please recreate the table lineitem from the TPC-H benchmark data
-- if you do not have it already. Then, check which compression
-- scheme is used for the columns of this table. You can use the
-- following query to check the compression scheme for the columns
-- of the table lineitem:
.open './lineitem.db'

SELECT row_group_id,
       column_name, column_id,
       segment_type, segment_id,
       start, count,
       compression,
       stats,
       persistent
FROM   pragma_storage_info('lineitem')
WHERE  segment_type <> 'VALIDITY'
ORDER BY row_group_id, segment_id;

-- Please report the compression scheme used for the columns
-- - l_orderkey
-- - l_quantity
-- - l_returnflag
-- - l_shipmode
-- - l_comment
--------------------------------------------------------------------------------
-- Solution:

-- l_orderkey:      BitPacking
-- l_quantity:      BitPacking
-- l_returnflag:    Dictionary
-- l_shipmode:      Dictionary
-- l_comment:       FSST

-- This was the case for all Row-Group partitions!

--------------------------------------------------------------------------------
-- Task (b) i.
--------------------------------------------------------------------------------
-- Similar to file 023-compression.sql, create a database compressed.db
-- with table t with 180K rows (you can use the range()/generate_series() function)
-- and add the following columns:
-- - a text column with a common prefix `sha256('salt')` and a
--   unique suffix for each row, e.g. `sha256(i :: text)`
-- - a column of with random double values (you can use the random() function)
-- - a column with alternating boolean values (you can use the modulo operator %)
--
-- Then, check the size of the database compressed.db, and the compression
-- scheme used for the columns of table t. Please try to find an explanation
-- for the compression scheme used for each column.
--------------------------------------------------------------------------------
-- Solution:

.open 'resources/compressed.db'


CREATE TABLE t AS
SELECT
    sha256('salt') || sha256(i::VARCHAR) AS textCol,
    random() AS randomDoubleCol,
    (i % 2 = 0) AS altBoolCol
FROM range(0, (180* 1024)) tbl(i); -- Interpreting K as Kibi = 1024




-- Checking row numbers:
SELECT count(*) FROM t;

-- Output: 184320 (180 Kibi)


-- Checking the compression scheme:
SELECT column_name, compression
FROM pragma_storage_info('t')
WHERE segment_type <> 'VALIDITY'
GROUP BY column_name, compression
ORDER BY column_name;

-- Output:
-- ┌─────────────────┬─────────────┐
-- │   column_name   │ compression │
-- │     varchar     │   varchar   │
-- ├─────────────────┼─────────────┤
-- │ altBoolCol      │ BitPacking  │
-- │ randomDoubleCol │ ALPRD       │
-- │ textCol         │ FSST        │
-- └─────────────────┴─────────────┘

--BitPacking (altBoolCol):
--This kinda bugs me, because what I would have expected is that duckDB simply stores true as 1 and False as 0.
--So that it directly uses only 1 bit per cell and then apply RLE to even further reduce the space 
-- (which is in this alternating 1, 0 col not effective but either way I would have expected single bits 
-- as value which is via BitPacking not any further compressable since 1 bit is the smallest unit we can reach).
--But what seems to happen here is that each value gets first saved as internal Integer maybe int6 000001 and 000000
--and then bitPacking reduces it to single bits.


--ALPRD (randomDoubleCol):
--ALPRD seems to splits each floating-point number into a prefix (high-order bits) and a suffix (low-order bits) 
--at a calculated bit boundary. The prefix is compressed using a small dictionary, 
--explointing the fact that many doubles hsare common exponent patterns or high-bit structures. 
--The suffix is bit-packed to save space without loss.
--This method is effective for compressing our column, because it balances adaptability and compression ratio.

-- > Citation: Raab, A., Boncz, P., & Markl, V. (2023). 
-- > Column Storage Layouts for Efficient Query Execution in DuckDB. 
-- > Proceedings of the VLDB Endowment, 16(9). https://ir.cwi.nl/pub/33334/33334.pdf


--FSST (textCol):
--The text column has a long, repeated prefix (sha256('salt')) and a unique suffix. So FSST is fully expected here:
--FSST is great for compressing strings with common patterns or repeated parts, by generating an encoding via a dictionary
-- (1=salt, 2=..., 3=...) and describing entrys as tuples of combinations eg. (1, 2) = 'salt' + 'restTextFromEntry#2'


--------------------------------------------------------------------------------
-- Task (b) ii.
--------------------------------------------------------------------------------
-- Now
-- Copy table t from compressed to uncompressed database uncompressed.db.
-- Use `PRAGMA force_compression = 'Uncompressed'` to force no compression
-- in the uncompressed database.
--
-- Then, check the size of the database uncompressed.db, and the compression
-- scheme used for the columns of table t (which should now be uncompressed).
-- You can use the same queries as above.
--
-- Please report the database size of uncompressed.db
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
.open 'resources/uncompressed.db'

PRAGMA force_compression = 'Uncompressed';

-- copy t from compressed.db:
ATTACH 'resources/compressed.db' AS comp;
CREATE TABLE t AS SELECT * FROM comp.t;
DETACH comp;

-- check comrepssion status:
SELECT column_name, compression
FROM pragma_storage_info('t')
WHERE segment_type <> 'VALIDITY'
GROUP BY column_name, compression
ORDER BY column_name;

-- Output:
--┌─────────────────┬──────────────┐
--│   column_name   │ compression  │
--│     varchar     │   varchar    │
--├─────────────────┼──────────────┤
--│ altBoolCol      │ Uncompressed │
--│ randomDoubleCol │ Uncompressed │
--│ textCol         │ Uncompressed │
--└─────────────────┴──────────────┘

--uncompressed size:
--26 MB 

--compressed size:
--9.7 MB compressed.db!