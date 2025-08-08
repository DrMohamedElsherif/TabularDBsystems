--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 01
-- Exercise 02
--------------------------------------------------------------------------------
-- Imagine you want to plan the chore chart of your living community using an
-- RDBMS. The chart is expected to provide an assignment of the services
-- {TRASH, KITCHEN, BATHROOM} to the flatmates {Annika, Pierre, Leonie} on a
-- weekly basis. The relational model implies that your chart is represented in
-- a tabular form. Here are three possible variants of a CHART relation:
-- ┌────────┐
-- │ CHART1 │
-- ├────────┼─────────────────┬────────┬──────────┐
-- │ week   │ Annika          │ Pierre │ Leonie   │
-- ├────────┼─────────────────┼────────┼──────────┤
-- │ 49     │ TRASH & KITCHEN │ null   │ BATHROOM │
-- │ 50     │ BATHROOM        │ TRASH  │ KITCHEN  │
-- └────────┴─────────────────┴────────┴──────────┘
-- ┌────────┐
-- │ CHART2 │
-- ├────────┼────────┬─────────┬──────────┐
-- │ week   │ TRASH  │ KITCHEN │ BATHROOM │
-- ├────────┼────────┼─────────┼──────────┤
-- │ 49     │ Annika │ Annika  │ Leonie   │
-- │ 50     │ Pierre │ Leonie  │ Annika   │
-- └────────┴────────┴─────────┴──────────┘
-- ┌────────┐
-- │ CHART3 │
-- ├────────┼──────────┬──────────┐
-- │ week   │ flatmate │ service  │
-- ├────────┼──────────┼──────────┤
-- │ 49     │ Annika   │ TRASH    │
-- │ 49     │ Annika   │ KITCHEN  │
-- │ 49     │ Leonie   │ BATHROOM │
-- │ 50     │ Annika   │ BATHROOM │
-- │ 50     │ Pierre   │ TRASH    │
-- │ 50     │ Leonie   │ KITCHEN  │
-- └────────┴──────────┴──────────┘
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- For each of the three variants, write down the SQL DDL statements to
-- create the table and the SQL DML statements to insert the data. You can
-- assume that the week is represented as an integer and the flatmates are
-- represented as text values.
--
-- For each of the three variants, add appropriate constraints to the
-- relation schema, e.g., NOT NULL, UNIQUE, CHECK, PRIMARY KEY, etc.,
-- and explain your choices.
--------------------------------------------------------------------------------
-- Solution:

CREATE TYPE SERVICE AS ENUM ('TRASH', 'KITCHEN', 'BATHROOM');
CREATE TYPE FLATMATE AS ENUM('Annika', 'Pierre', 'Leonie');
----------------------------------------------------------------

CREATE TABLE CHART1 (
    week    INTEGER PRIMARY KEY,
    Annika  TEXT,
    Pierre  TEXT,
    Leonie  TEXT,

    CHECK (Annika IS NULL OR Annika ~ '^(TRASH|KITCHEN|BATHROOM)( & (TRASH|KITCHEN|BATHROOM))*$'),
    CHECK (Pierre IS NULL OR Pierre ~ '^(TRASH|KITCHEN|BATHROOM)( & (TRASH|KITCHEN|BATHROOM))*$'),
    CHECK (Leonie IS NULL OR Leonie ~ '^(TRASH|KITCHEN|BATHROOM)( & (TRASH|KITCHEN|BATHROOM))*$')
);
-- The checks ensure that only the three specified services can be entered into the table.
-- This WILL be obstructive if we want to add other services beside the existing ones!

INSERT INTO CHART1 (week, Annika, Pierre, Leonie)
VALUES  (49, 'TRASH & KITCHEN', null, 'BATHROOM'),
        (50, 'BATHROOM', 'TRASH', 'KITCHEN');

-- Show table:
FROM CHART1;

----------------------------------------------------------------

CREATE TABLE CHART2 (
    week        INTEGER     PRIMARY KEY,
    TRASH       FLATMATE    NOT NULL,
    KITCHEN     FLATMATE    NOT NULL,
    BATHROOM    FLATMATE    NOT NULL
);
-- The enum FLATMATE ensures that only people part of the living community are assigned to services!
-- This WILL be obstrictive as soon as the member changes - It may be better if we just would leafe it as TEXT TYPE
-- to ensure easier changes in the future

INSERT INTO CHART2 (week, TRASH, KITCHEN, BATHROOM)
VALUES  (49, 'Annika', 'Annika', 'Leonie'),
        (50, 'Pierre', 'Leonie', 'Annika');

-- Show table:
FROM CHART2;

----------------------------------------------------------------

CREATE TABLE CHART3 (
    week        INTEGER     NOT NULL,
    flatmate    FLATMATE    NOT NULL,
    service     SERVICE     NOT NULL,
    PRIMARY KEY (week, service)
);
-- The enums FLATMATE and SERVICE ensure only the living community members are assigned valid services
-- While this is effective as long none of the enums changes. This not very future proof because there
-- will be definitly new tasks or new members (while old members will leave). Since we can Expect so
-- much change in those enum types it would be better to just leave it as TEXT

INSERT INTO CHART3 (week, flatmate, service)
VALUES  (49, 'Annika', 'TRASH'),
        (49, 'Annika', 'KITCHEN'),
        (49, 'Leonie', 'BATHROOM'),
        (50, 'Annika', 'BATHROOM'),
        (50, 'Pierre', 'TRASH'),
        (50, 'Leonie', 'KITCHEN');

-- Show table:
FROM CHART3;


--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Explain what changes to the schema and/or instance are needed for every
-- table, if we want to:
-- i. Add the plan for week 51 (Annika: KITCHEN, Pierre: BATHROOM, Leonie: TRASH).
-- ii. Add an additional service COOK for Pierre in week 50.
-- iii. Switch Leonie with a new flatmate Adrian.
--
-- Note: You can assume, that there are no entries for week 51 in the tables.
--------------------------------------------------------------------------------
-- Solution:

-- case i.)
-- No changes in any of the 3 charts necessary!

-- case ii.)
-- CHART1 needs a whole new table instance since the CHECKs have to be updated to include COOK.
-- CHART2 needs just a new column COOK.
-- CHART3 needs a whole new table instance since we need a new Enum type that includes COOK.

-- case iii.)
-- CHART1 needs to rename a column into Leonie.
-- CHART2 needs a new table instance since the enum class FLATMATE needs to be updated with Adrian.
-- CHART3 needs a new table instance for the same reason CHART2 would need a new one.




-- IMPLEMENTATIONS: ------------------------------------------------
-- case i.)
-- see task (c)


-- case ii.)
-- For CHART1 we need to create and migrate to a new table because CHECKs can't be updated on a instantiated table:
CREATE TABLE CHART1_NEW (
    week INTEGER PRIMARY KEY,
    Annika  TEXT,
    Pierre  TEXT,
    Leonie  TEXT,

    CHECK (Annika IS NULL OR Annika ~ '^(TRASH|KITCHEN|BATHROOM|COOK)( & (TRASH|KITCHEN|BATHROOM|COOK))*$'),
    CHECK (Pierre IS NULL OR Pierre ~ '^(TRASH|KITCHEN|BATHROOM|COOK)( & (TRASH|KITCHEN|BATHROOM|COOK))*$'),
    CHECK (Leonie IS NULL OR Leonie ~ '^(TRASH|KITCHEN|BATHROOM|COOK)( & (TRASH|KITCHEN|BATHROOM|COOK))*$')
);
INSERT INTO CHART1_NEW
SELECT * FROM CHART1;

UPDATE CHART1_NEW
SET Pierre = Pierre || ' & COOK'
WHERE week = 50;

-- CHART2 needs a whole new column whoch can be easily added with ALTER
-- see task (c)

-- CHART3 rewuires the enum to be updated. Since this is not simply possible to add a new value to the enum type,
-- I decided to make a new table with an updated enum and migrate the content.
CREATE TYPE SERVICE_UPDATE AS ENUM ('TRASH', 'KITCHEN', 'BATHROOM', 'COOK');

CREATE TABLE CHART3_NEW (
    week        INTEGER         NOT NULL,
    flatmate    FLATMATE        NOT NULL,
    service     SERVICE_UPDATE  NOT NULL,
    PRIMARY KEY (week, service)
);

INSERT INTO CHART3_NEW (week, flatmate, service)
SELECT * FROM CHART3;

INSERT INTO CHART3_NEW (week, flatmate, service)
VALUES  (50, 'Pierre', 'COOK');


-- case iii.) I intrep. this as "Leonie is leaving and now there is Adrian and no Leonie!!"
-- CHART1 needs a rename of the column 'Leonie'
-- see task (c)

-- CHART2 needs a whole new table since the enum needs to be updated:
-- When migrating, we have to exchange Leonie with Adrian.
CREATE TYPE FLATMATE_UPDATE AS ENUM('Annika', 'Pierre', 'Adrian');

CREATE TABLE CHART2_NEW (
    week        INTEGER     PRIMARY KEY,
    TRASH       FLATMATE_UPDATE    NOT NULL,
    KITCHEN     FLATMATE_UPDATE    NOT NULL,
    BATHROOM    FLATMATE_UPDATE    NOT NULL
);

INSERT INTO CHART2_NEW (week, TRASH, KITCHEN, BATHROOM)
SELECT
  week,
  CASE TRASH WHEN 'Leonie' THEN 'Adrian' ELSE TRASH END,
  CASE KITCHEN WHEN 'Leonie' THEN 'Adrian' ELSE KITCHEN END,
  CASE BATHROOM WHEN 'Leonie' THEN 'Adrian' ELSE BATHROOM END
FROM CHART2;

-- CHART3 needs a similar change than in case ii. but now for the updated FALTMATE_UPDATE enum
-- (NOTE: FLATMATE_UPDATE was created above already!)
-- When migrating, we have to exchange Leonie with Adrian.
CREATE TABLE CHART3_NEW2 (
    week        INTEGER         NOT NULL,
    flatmate    FLATMATE_UPDATE NOT NULL,
    service     SERVICE         NOT NULL,
    PRIMARY KEY (week, service)
);

INSERT INTO CHART3_NEW2 (week, flatmate, service)
SELECT
  week,
  CASE flatmate WHEN 'Leonie' THEN 'Adrian' ELSE flatmate END,
  service
FROM CHART3;

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Specify INSERT, UPDATE, and DELETE statements for those tables in task
-- i. to iii. that only need their instance changed.
--
-- Hint: For i., a simple INSERT statement is sufficient. However, for ii. there
-- already exists a row for week 50 in the instance of CHART1. You need to
-- update this row.
-- Task iii. requires you to rename a column using the ALTER TABLE statement.
-- https://duckdb.org/docs/stable/sql/statements/alter_table#rename-column
-- https://duckdb.org/docs/stable/sql/statements/insert
-- https://duckdb.org/docs/stable/sql/statements/update
--------------------------------------------------------------------------------
-- Solution:

-- case i.)
-- No chnages needed for CHART1:
INSERT INTO CHART1 (week, Annika, Pierre, Leonie)
VALUES  (51, 'KITCHEN', 'BATHROOM', 'TRASH');

-- No changes needed for CHART2
INSERT INTO CHART2 (week, TRASH, KITCHEN, BATHROOM)
VALUES  (51, 'Leonie', 'Annika', 'Pierre');

-- No changes needed for CHART3
INSERT INTO CHART3 (week, flatmate, service)
VALUES  (51, 'Leonie', 'TRASH'),
        (51, 'Annika', 'KITCHEN'),
        (51, 'Pierre', 'BATHROOM');


-- case ii.)
ALTER TABLE CHART2 ADD COLUMN COOK FLATMATE;

UPDATE CHART2
SET COOK = 'Pierre'
WHERE week = 50;


-- case iii.)
ALTER TABLE CHART1 RENAME COLUMN Leonie TO Adrian;


--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- In the relational model, relation schemas are assumed to be stable while
-- instances change frequently. Given this, which relation is the best choice to
-- represent the chart? Why?
--------------------------------------------------------------------------------
-- Solution:
-- In task (a) we already discussed the difficulties of strict column typing! The more specific a type is set for
-- a column the more sure one must be that nothin will change in this type!
-- If we'd use simple TEXT types for service and flatmate, CHART3 is definitly the esiest table to maintain!
-- That's because we would not change much about the scheme (i.e having to add a new column if a new service arises
-- even if that service is a one time thing. (for example "repair window") or having to create whole new instances
-- of tables.)
-- In our opoinion the best "future proof table" would be:
--
CREATE TABLE CHART3_OPTIMAL (
    week        INTEGER     NOT NULL,
    flatmate    TEXT    NOT NULL,
    service     TEXT     NOT NULL,
    PRIMARY KEY (week, service)
);

-- To ensure that only valud flatmates or services are assigned. One could build a simple GUI and manage valid options
-- via drop down menus which might be esier to update whether than instanciate whole new tables each time the flatmate
-- member list changes or new services arise.
