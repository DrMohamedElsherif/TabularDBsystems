--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 01
-- Feedback
-- TOTAL POINTS 26/27
--------------------------------------------------------------------------------
-- Exercise 01

-- Task (a): NOT NULL is missing in id. You don't have to add it, since you use
-- PRIMARY KEY, but it helps with clarity.

-- Points: 3/3

--------------------------------------------------------------------------------

-- Task (b): Great!

-- Points: 3/3

--------------------------------------------------------------------------------

-- Task (c): Great!

-- Points: 3/3

--------------------------------------------------------------------------------

-- Task (d): Great!

-- Points: 3/3

--------------------------------------------------------------------------------

-- Task (e): Great!

-- Points: 3/3

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Exercise 02

-- Task (a): For CHART1 the CHECK for the different services is not wrong. As
-- mentioned we would rather expect to add new services to the table. However
-- a CHECK for week is necessary, as a year has only 52 weeks and we'd to check
-- that the week number is between 1 and 52.
-- With SERVICE and FLATMATE you make your table more rigid, i.e. making
-- future changes harder.
-- For CHART3 we want the PRIMARY KEY to include week, flatmate, and service

-- Points: 2/3

--------------------------------------------------------------------------------

-- Task (b):
-- (i) Correct! We would only need to add the new rows.
-- (ii) For CHART1 if TEXT is used, a simple UPDATE or ON CONFLICT DO UPDATE is
-- sufficient. For CHART3 correct if ENUM is used. If TEXT is used  we can add 
-- a new row with the values (50, 'Pierre', 'COOK').
-- (iii) For CHART2 and CHART3, we do not need to change the schema if TEXT is
-- used.

-- Points: 3/3

--------------------------------------------------------------------------------

-- Task (c): Please try to tidy up your assigment before hand in.
-- (i) Correct!
-- (ii) You correctly identify the limitation caused by CHECK constraints in 
-- CHART1 and the immutability of ENUM types in CHART3. Creating new tables with 
-- relaxed constraints or extended enums is technically accurate. However, the 
-- task specifically states to only change the instance when possible. As 
-- mentioned above using TEXT for service would lead to more flexibility.
-- (iii) Correct for CHART1. For CHART2 and CHART3, if TEXT types are used, 
-- UPDATE ... SET ... WHERE flatmate = 'Leonie' is sufficient.

-- Points: 3/3

--------------------------------------------------------------------------------

-- Task (d): Good!

-- Points: 3/3

--------------------------------------------------------------------------------