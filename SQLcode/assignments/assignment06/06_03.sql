--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 06
-- Exercise 03
--------------------------------------------------------------------------------
-- DuckDB's EXPLAIN facility reveals exactly how the DBMS executes a SQL
-- query Q: the system dumps the query plan for Q which shows how data flows
-- from the bottom operator to the root which represents the query result.
-- During TaDa we will frequently consult these plans to understand query
-- behavior and performance.
--
-- Here, let us practise how to read these plans. We "turn the tables":
-- You are asked to study a given plan (namely the output for
-- EXPLAIN ANALYZE for an unknown query Q) and hand-in the original
-- SQL query Q.  (Executing EXPLAIN ANALYZE Q will thus produce the
-- plans you find below.)
-- Note:
-- - The queries Q1 and Q2 both operate over the well-known table
--   vehicles(vehicle,kind,seats,"wheels?",pid).
-- - Queries Q1 and Q2 exclusively use SQL constructs that we have
--   discussed in TaDa so far.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please reconstruct the SQL query Q1 such that EXPLAIN ANALYZE Q1
-- leads to the following plan:
--
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
-- │ sum_no_overflow(#0) FILTER│
-- │    (WHERE #1) Filter: #1  │
-- │                           │
-- │           1 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │         PROJECTION        │
-- │    ────────────────────   │
-- │           seats           │
-- │          wheels?          │
-- │                           │
-- │           5 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │         TABLE_SCAN        │
-- │    ────────────────────   │
-- │      Table: vehicles      │
-- │   Type: Sequential Scan   │
-- │                           │
-- │        Projections:       │
-- │          wheels?          │
-- │           seats           │
-- │                           │
-- │    Filters: kind!='bus'   │
-- │                           │
-- │           5 Rows          │
-- │          (0.00s)          │
-- └───────────────────────────┘
--
--------------------------------------------------------------------------------
-- Solution:

.open './resources/vehicles.db';

EXPLAIN ANALYZE
SELECT
    COUNT(*) AS total,
    SUM(seats) FILTER (WHERE "wheels?")
FROM vehicles
WHERE kind != 'bus';

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Please reconstruct the SQL query Q2 such that EXPLAIN ANALYZE Q2
-- leads to the following plan:
--
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
-- │         PROJECTION        │
-- │    ────────────────────   │
-- │    ((vehicle || '-') ||   │
-- │          vehicle)         │
-- │        (seats * 2)        │
-- │                           │
-- │           3 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │           LIMIT           │
-- │    ────────────────────   │
-- │           3 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │         PROJECTION        │
-- │    ────────────────────   │
-- │             #1            │
-- │             #2            │
-- │                           │
-- │           6 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │           FILTER          │
-- │    ────────────────────   │
-- │          wheels?          │
-- │                           │
-- │           6 Rows          │
-- │          (0.00s)          │
-- └─────────────┬─────────────┘
-- ┌─────────────┴─────────────┐
-- │         TABLE_SCAN        │
-- │    ────────────────────   │
-- │      Table: vehicles      │
-- │   Type: Sequential Scan   │
-- │                           │
-- │        Projections:       │
-- │          wheels?          │
-- │          vehicle          │
-- │           seats           │
-- │                           │
-- │           7 Rows          │
-- │          (0.00s)          │
-- └───────────────────────────┘
--------------------------------------------------------------------------------
-- Solution:

EXPLAIN ANALYZE
SELECT
    (vehicle || '-' || vehicle),
    (seats * 2)
FROM vehicles
WHERE "wheels?"
LIMIT 3;

--------------------------------------------------------------------------------
