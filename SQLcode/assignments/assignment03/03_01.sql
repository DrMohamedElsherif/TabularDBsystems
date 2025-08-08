--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 03
-- Exercise 01
--------------------------------------------------------------------------------
-- On the previous assignment, you learned how to load CSV files into DuckDB,
-- and that the CSV files need to be well-formed in order to be loaded correctly.
--
-- In this exercise, you will learn how to deal with broken CSV files and how to
-- fix them with the help of DuckDB.
--
-- As a first example, we will use the file `broken.csv` that you have
-- already seen in the previous assignment. The file contains some CSV data
-- that you want to query using DuckDB. We try to load the file using the
-- `read_csv` function, but the file is broken and cannot be loaded without
-- any issues:

FROM read_csv('resources/broken.csv',
    header = true,
    delim = ',',
    columns = {
        'id' : 'INTEGER',
        'name' : 'VARCHAR',
        'age' : 'text'
    },
    ignore_errors = true,
    store_rejects = true
);

-- ┌───────┬───────────────────┬─────────┐
-- │  id   │       name        │   age   │
-- │ int32 │      varchar      │ varchar │
-- ├───────┼───────────────────┼─────────┤
-- │     1 │ John Doe          │ 25      │
-- │     2 │ Jane Smith        │ thirty  │
-- │     3 │ Alice, Wonderland │ 28      │
-- │     5 │ Charlie           │ 29      │
-- └───────┴───────────────────┴─────────┘

-- This works, but now we are missing the row with id 4. To debug this, we have
-- to check the `rejects` table that was created by the `store_rejects` option:

SELECT line, error_type, csv_line, error_message
FROM reject_errors;

-- This gives us the following output:
-- ┌────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────────────────────────────────────────────────────────────────────────┐
-- │  line  │                                                             error_type                                                              │      csv_line      │                                    error_message                                     │
-- │ uint64 │ enum('cast', 'missing columns', 'too many columns', 'unquoted value', 'line size over maximum', 'invalid unicode', 'invalid state') │      varchar       │                                       varchar                                        │
-- ├────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
-- │      5 │ TOO MANY COLUMNS                                                                                                                    │ 4,Bob, O'Connor,35 │ Expected Number of Columns: 3 Found: 4                                               │
-- │      7 │ CAST                                                                                                                                │ 6|NULL|30          │ Error when converting column "id". Could not convert string "6|NULL|30" to 'INTEGER' │
-- │      7 │ MISSING COLUMNS                                                                                                                     │ 6|NULL|30          │ Expected Number of Columns: 3 Found: 1                                               │
-- │      7 │ MISSING COLUMNS                                                                                                                     │ 6|NULL|30          │ Expected Number of Columns: 3 Found: 2                                               │
-- └────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────────────────────────────────────────────────────────────────────────┘

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- i. Please explain why the error occurs.
-- ii. Please fix the CSV file so that it can be loaded without any errors.
--------------------------------------------------------------------------------
-- Solution:

-- Problems:
-- The error messages are quite clear:
-- line 5) after Bob, there is an additional commata which indicates (falsly) a new column in csv, thus the line has 4 instead of the expected 3 rows
-- line 7) Several errors are reported here:
--               - First a CAST error. Because the csv parser has commata set as delimiter, it does not recognize the pipe "|" symbol which results
--                 in a string "6|NULL|30" instead of the expected 3 columns. Thus the parser tries to cast the whole string to an integer which fails.
--               - The first MISSING COLUMNS error has the same reason as the CAST error. The parser expects 3 columns but only finds 1. Since 
--                 the string "6|NULL|30" couldn't be split into 3 columns with a ',' delimiter.
--               - The second MISSING COLUMNS error is the same as the first one, but this time the parser found 2 columns instead of 3. This is because
--                 the parser used a fallback or recovery strategy that is applied when the parser encounters an error. How exactly the parser yields
--                 2 columns is not clear to me. If it would just try every known delimiter it would have a success using '|' as delimiter. But this is not the case.
--                 Thus my guess is that it kinda loops over every letter in the string and tries to cast it to the specified columns type.
--                 Like it splits it into 6 and "NULL|30", recognizes the 6 as integer and fails to split the rest since column name and age are both types that accept strings.
--                 Thus the two found columns.

-- load the fixed csv file:
FROM read_csv('resources/broken_fixed.csv',
    header = true,
    delim = ',',
    columns = {
        'id' : 'INTEGER',
        'name' : 'VARCHAR',
        'age' : 'text'
    });

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- File `oh_gawd_why.csv` contains some CSV data that you want to query
-- But the file is seriously broken and cannot be loaded. With the just
-- learned techniques, please fix the CSV file so that it can be loaded
-- without any errors. You can use the `store_rejects` option to store
-- the rejected rows in a separate table. This will help you to debug
-- the issues with the CSV file.
--
-- Note: You need to be careful when reading from the `reject_errors` table
-- because this table will **not** be automatically cleared when you
-- repeat the `read_csv` command. You need to clear it manually
-- before each run. You can do this by running the following command:
-- TRUNCATE reject_errors;
--
-- After you have fixed the CSV file, the `reject_errors` table should be empty.

FROM read_csv('resources/oh_gawd_why_fixed.csv',
    header = true,
    delim = ',',
    columns = {
        'id' : 'INTEGER',
        'name' : 'VARCHAR',
        'age' : 'INTEGER',
        'email' : 'VARCHAR',
        'signup_date' : 'DATE',
        'score': 'FLOAT'
    },
    ignore_errors = true,
    store_rejects = true
);

-- NOTE: For line 12: unkown date: I set the date to null because we can't be sure if they meant like moth 12 or month 02.

SELECT line, error_type, csv_line, error_message
FROM reject_errors;
