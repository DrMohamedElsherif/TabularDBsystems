--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 09
-- Exercise 01
--------------------------------------------------------------------------------
-- In this exercise, we will use more SQL features and train our skills in
-- writing SQL queries.
--------------------------------------------------------------------------------
-- Task (a) — [E]
--------------------------------------------------------------------------------
-- This tasks and the following ones use the starwars database `starwars.db`.

ATTACH 'starwars.db';
SET schema 'starwars';

-- John Williams is the musical mastermind behind most of the big-screen Star Wars movies
-- (those listed in table films). But other composers had an impact, too (e.g., in TV shows).
-- List the names of those composers whose music is not associated with any big-screen
-- Star Wars movie.
--------------------------------------------------------------------------------
-- Solution:

-- select all composer that EXCLUSIVELY worked on shows:
-- IDEA:
-- two sets: one which contains all composers of Movies
--           one wich contains all composers not in Movies
-- Removing Movie Composer from Not movie composer set retains all that exclusively worked on non movies

SELECT DISTINCT composer
  FROM music
  WHERE type != 'Movie'
    AND composer NOT IN (
      SELECT composer FROM music WHERE type = 'Movie'
    );

--> ┌──────────────────┐
--> │     composer     │
--> │     varchar      │
--> ├──────────────────┤
--> │ Kevin Kiner      │
--> │ Ludwig Göransson │
--> └──────────────────┘

--------------------------------------------------------------------------------
-- Task (b) — [E]
--------------------------------------------------------------------------------
-- One species is represented twice in table "species" with all columns
-- containing identical data (except column "id").  Write a query
-- that returns a single row containing the duplicate data of that species
-- (excluding column "id").
--------------------------------------------------------------------------------
-- Solution:

-- IDEA:
-- GRoup by all excluding the ids

SELECT * EXCLUDE id
  FROM species
  GROUP BY ALL
  HAVING COUNT(*) > 1;

--> ┌──────────┬────────────────┬─────────────┬────────────────┬───┬──────────────────┬──────────┬───────────┐
--> │   name   │ classification │ designation │ average_height │ … │ average_lifespan │ language │ homeworld │
--> │ varchar  │    varchar     │   varchar   │     double     │   │      double      │ varchar  │  varchar  │
--> ├──────────┼────────────────┼─────────────┼────────────────┼───┼──────────────────┼──────────┼───────────┤
--> │ Kaminoan │ Amphibian      │ Sentient    │      2.0       │ … │       80.0       │ Kaminoan │ Kamino    │
--> ├──────────┴────────────────┴─────────────┴────────────────┴───┴──────────────────┴──────────┴───────────┤
--> │ 1 rows                                                                            10 columns (7 shown) │
--> └────────────────────────────────────────────────────────────────────────────────────────────────────────┘

--------------------------------------------------------------------------------
-- Task (c) — [E]
--------------------------------------------------------------------------------
-- Write a query that finds the name of two characters that died
-- youngest and oldest (tag the rows to indicate who is who):
--
-- ┌──────────┬──────────┐
-- │   name   │   age    │
-- ├──────────┼──────────┤
-- │ ‹name₁›  │ youngest │
-- │ ‹name₂›  │ oldest   │
-- └──────────┴──────────┘

--------------------------------------------------------------------------------
-- Solution:

-- IDEA:
-- Calculate the differences year_died - year:born to get the age
-- then 

SELECT DISTINCT name, 'youngest' AS tag
  FROM characters
  WHERE year_died - year_born = (
    SELECT MIN(year_died - year_born)
    FROM characters
    WHERE year_died IS NOT NULL AND year_born IS NOT NULL
  )
  AND year_died IS NOT NULL AND year_born IS NOT NULL
  
  UNION ALL
  
  SELECT DISTINCT name, 'oldest' AS tag
  FROM characters
  WHERE year_died - year_born = (
    SELECT MAX(year_died - year_born)
    FROM characters
    WHERE year_died IS NOT NULL AND year_born IS NOT NULL
  )
  AND year_died IS NOT NULL AND year_born IS NOT NULL;

--> ┌──────────┬──────────┐
--> │   name   │   tag    │
--> │ varchar  │ varchar  │
--> ├──────────┼──────────┤
--> │ Jyn Erso │ youngest │
--> │ Yoda     │ oldest   │
--> └──────────┴──────────┘

--------------------------------------------------------------------------------
-- Task (d) — [E]
--------------------------------------------------------------------------------
-- Which films (title, year) make up the pequels (released after Return of the Jedi,
-- before The Force Awakens)?
--------------------------------------------------------------------------------
-- Solution:

-- IDEA:
-- List the Movies between "Return of the Jedi" and "The Force Awakens"

SELECT title, release_date
  FROM films
  WHERE release_date > (
      SELECT release_date FROM films WHERE title = 'Return of the Jedi'
  )
  AND release_date < (
      SELECT release_date FROM films WHERE title = 'The Force Awakens'
  )
  ORDER BY release_date;

--> ┌──────────────────────┬──────────────┐
--> │        title         │ release_date │
--> │       varchar        │     date     │
--> ├──────────────────────┼──────────────┤
--> │ The Phantom Menace   │ 1999-05-19   │
--> │ Attack of the Clones │ 2002-05-16   │
--> │ Revenge of the Sith  │ 2005-05-19   │
--> └──────────────────────┴──────────────┘

--------------------------------------------------------------------------------
-- Task (e) — Warning: this task is a bit tricky!
--------------------------------------------------------------------------------
-- Which droids (name) appear in all films directed by George Lucas?
--------------------------------------------------------------------------------
-- Solution:

-- IDEA:
-- Select all films that are directed by G. Lucas and count them
-- then with any droid name, check  how often G. Lucas directed those movies
-- if count is equal, all films the dorid occurred in were directed by Lucas

SELECT name
FROM droids
WHERE (
  SELECT COUNT(*)
  FROM films
  WHERE director = 'George Lucas'
) = (
  SELECT COUNT(*)
  FROM films f
  WHERE director = 'George Lucas'
    AND f.title = ANY(droids.films)
);

--> ┌─────────┐
--> │  name   │
--> │ varchar │
--> ├─────────┤
--> │ R2-D2   │
--> │ C-3PO   │
--> └─────────┘

--------------------------------------------------------------------------------
