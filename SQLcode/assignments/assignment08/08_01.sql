--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 08
-- Exercise 01
--------------------------------------------------------------------------------
-- In the lecture, we learned a lot more about SQL, multi-table queries
-- and joins in particular.   We will use this knowledge now to formulate
-- more complex queries.
--
-- The file `beer.sql` contains the table schemata and states of a
-- beer/bar database. It contains the following tables:
-- - `Bars`: stores information about bars
-- - `Beers`: stores information about different beers
-- - `Drinkers`: stores information about customers
-- - `Likes`: stores which drinkers like which beers
-- - `Sells`: stores which bars sell which beers and their prices
-- - `Frequents`: stores which drinkers visit which bars
--
-- For your conveniece, we have also prepared a DuckDB database file
-- that contains these tables.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Write a query that returns the names of all bars that sell a beer with an
-- alcohol content greater than 5.0. Please also return the name of the beer
-- and its alcohol content. The result should be ordered by the name of the bar.
--------------------------------------------------------------------------------
-- Solution:

SELECT DISTINCT Bars.name AS bar_name, Beers.name AS beer_name, Beers.alcoholContent
  FROM Sells
  JOIN Beers ON Sells.beer_id = Beers.id
  JOIN Bars ON Sells.bar_id = Bars.id
  WHERE Beers.alcoholContent > 5.0
  ORDER BY Bars.name;

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Write a query that returns the names of all drinkers who like beers with an
-- alcohol content less or equal than 5.0. Please also return the name of the beer
-- and its alcohol content. The result should be ordered by the name of the
-- drinker.
--------------------------------------------------------------------------------
-- Solution:

SELECT DISTINCT Drinkers.name AS drinker_name, Beers.name AS beer_name, Beers.alcoholContent
  FROM Likes
  JOIN Beers ON Likes.beer_id = Beers.id
  JOIN Drinkers ON Likes.drinker_id = Drinkers.id
  WHERE Beers.alcoholContent <= 5.0
  ORDER BY Drinkers.name;

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Write a query that returns the names of all bars that sell beers with an
-- alcohol content >= 5.0 and that are frequented by drinkers who like
-- beers with an alcohol content less or equal than 5.0. Please also return the
-- name of the beer and its alcohol content. The result should be ordered by the
-- name of the bar.
--------------------------------------------------------------------------------
-- Solution:

SELECT DISTINCT Bars.name AS bar_name, Beers.name AS beer_name, Beers.alcoholContent
FROM Bars
JOIN Sells ON Bars.id = Sells.bar_id
JOIN Beers ON Sells.beer_id = Beers.id
WHERE Beers.alcoholContent >= 5.0
  AND EXISTS (
    SELECT 1
    FROM Frequents
    JOIN Likes ON Frequents.drinker_id = Likes.drinker_id
    JOIN Beers AS LikedBeers ON Likes.beer_id = LikedBeers.id
    WHERE Frequents.bar_id = Bars.id
      AND LikedBeers.alcoholContent <= 5.0
  )
ORDER BY Bars.name;


--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- Write a query that finds pairs of drinkers who like the same beer. Return the
-- names of both drinkers and the name of the beer they both like. To avoid
-- duplicate pairs, ensure the first drinker's name comes before the second
-- drinker's name alphabetically. Order the results by the beer name.
-- Note: This query requires a self-join on the `Drinkers` and `Likes` tables.
--------------------------------------------------------------------------------
-- Solution:

SELECT d1.name AS drinker1, d2.name AS drinker2, b.name AS beer_name
FROM Likes l1
JOIN Likes l2 ON l1.beer_id = l2.beer_id AND l1.drinker_id < l2.drinker_id
JOIN Drinkers d1 ON l1.drinker_id = d1.id
JOIN Drinkers d2 ON l2.drinker_id = d2.id
JOIN Beers b ON l1.beer_id = b.id
WHERE d1.name < d2.name
ORDER BY b.name;


--------------------------------------------------------------------------------
-- Task (e)
--------------------------------------------------------------------------------
-- Write a query that finds all bars that have no drinkers frequenting them
-- using an anti join. Return the bar names ordered alphabetically.
-- Note: This query uses DuckDB's explicit ANTI JOIN syntax.
--------------------------------------------------------------------------------
-- Solution:

SELECT Bars.name
FROM Bars
ANTI JOIN Frequents ON Bars.id = Frequents.bar_id
ORDER BY Bars.name;


--------------------------------------------------------------------------------
-- Task (f)
--------------------------------------------------------------------------------
-- Write a query that lists all beers and the bars that sell them, including
-- beers that aren't sold anywhere. Return the beer name, its alcohol content,
-- and the bar name. Order the results by beer name and bar name.
-- Note: This query requires a LEFT JOIN.
--------------------------------------------------------------------------------
-- Solution:

SELECT Beers.name AS beer_name, Beers.alcoholContent, Bars.name AS bar_name
FROM Beers
LEFT JOIN Sells ON Beers.id = Sells.beer_id
LEFT JOIN Bars ON Sells.bar_id = Bars.id
ORDER BY Beers.name, bar_name;


--------------------------------------------------------------------------------
-- Task (g)
--------------------------------------------------------------------------------
-- Write a query that lists all bars and beers combinations - both the bars that
-- sell beers and beers that aren't sold, alongside bars that don't sell any
-- beers. Return the bar name and beer name, ordered by bar name and beer name.
-- Note: This query requires a FULL OUTER JOIN.
--------------------------------------------------------------------------------
-- Solution:

SELECT Bars.name AS bar_name, Beers.name AS beer_name
FROM Bars
FULL OUTER JOIN Sells ON Bars.id = Sells.bar_id
FULL OUTER JOIN Beers ON Sells.beer_id = Beers.id
ORDER BY bar_name, beer_name;


--------------------------------------------------------------------------------
-- Task (h)
--------------------------------------------------------------------------------
-- Write a query that returns the name and age of those drinkers that
-- like (any) beer of type Ale.  Important: List each drinker only once.
-- Note: Do NOT use DISTINCT—instead rely on SEMI JOIN.
--------------------------------------------------------------------------------
-- Solution:

SELECT name, age
  FROM Drinkers
  WHERE id IN (
      SELECT drinker_id
      FROM Likes
      JOIN Beers ON Likes.beer_id = Beers.id
      WHERE Beers.type = 'Ale'
  );

--------------------------------------------------------------------------------
