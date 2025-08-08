--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 02
-- Exercise 01
--------------------------------------------------------------------------------

-- Given the following table `customers`:

CREATE TABLE customers (
    id INTEGER NOT NULL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT
);

INSERT INTO customers (id, first_name, last_name, email, phone) VALUES
    (1, 'John', 'Doe', 'john@doe', '1234567890'),
    (2, 'Jane', 'Smith', 'jane@smith', '0987654321'),
    (3, 'Alice', 'Johnson', 'alice@johnson', '5551234567'),
    (4, 'Bob', 'Brown', 'bob@brown', '5559876543');

-- We now want to add a new table `orders` to the database. The `orders` table should
-- contain the following columns:
-- - `order_id`: An integer that uniquely identifies each order (primary key).
-- - `customer_id`: An integer that references the `id` column in the `customers` table.
-- - `order_date`: A date that indicates when the order was placed.
-- - `total_amount`: A value of maximum seven digits with two decimal places that
--   indicates the total amount of the order.
--
-- The `customer_id` column should have a foreign key constraint that references the
-- `id` column in the `customers` table. The `order_date` column should have a default
-- value of the current date. The `total_amount` column should not allow null values.

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Write the SQL DDL statement to create the `orders` table with the specified
-- columns and constraints. Use appropriate data types for each column.
-- https://duckdb.org/docs/stable/sql/statements/create_table
--------------------------------------------------------------------------------
-- Solution:

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(7,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Query `FROM orders;` returns the following output:
-- ┌──────────┬─────────────┬────────────┬──────────────┐
-- │ order_id │ customer_id │ order_date │ total_amount │
-- │  int64   │    int64    │    date    │    double    │
-- ├──────────┼─────────────┼────────────┼──────────────┤
-- │        1 │           1 │ 2025-05-01 │        100.5 │
-- │        2 │           2 │ 2025-05-02 │       200.75 │
-- │        3 │           1 │ 2025-05-03 │        150.0 │
-- │        4 │           3 │ 2025-05-04 │       300.25 │
-- │        5 │           2 │ 2025-05-05 │         50.0 │
-- │        6 │           4 │ 2025-05-06 │        400.0 │
-- └──────────┴─────────────┴────────────┴──────────────┘
-- Write the SQL DML statement to load that data into the `orders` table.
-- https://duckdb.org/docs/stable/sql/statements/insert
--------------------------------------------------------------------------------
-- Solution:

INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
    (1, 1, DATE '2025-05-01', 100.50),
    (2, 2, DATE '2025-05-02', 200.75),
    (3, 1, DATE '2025-05-03', 150.00),
    (4, 3, DATE '2025-05-04', 300.25),
    (5, 2, DATE '2025-05-05', 50.00),
    (6, 4, DATE '2025-05-06', 400.00);

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Alice Johnson wants all her data to be deleted from the database.
-- However, the following error occurs when you try to delete her data from the
-- `customers` table:

-- DELETE FROM customers WHERE id = 3;
-- Constraint Error: Violates foreign key constraint because key "customer_id: 3"
-- is still referenced by a foreign key in a different table.

-- i. Please explain why this error occurs.
-- ii. Write the SQL DML statements to delete Alice Johnson's data from the `customers` table.
--------------------------------------------------------------------------------
-- Solution:

-- The error occurs because Alice Johnson (id = 3) has an order in the orders table. 
-- The foreign key constraint on orders.customer_id prevents deletion of a customer 
-- who is still referenced by any order.
-- To avoid the error we need to first delete her related orders, then delete the customer.

-- Another solution would be to set the customer_id in the orders table to NULL
-- for all orders related to the id of Alice Johnson, if the orders table allowed 
-- NULL values in that column. In that way the orders would still exist in the
-- orders table for later reference, but would not be related to any customer anymore.
-- However, in this case the orders table does not allow NULL values in the customer_id column.
-- Therefore, we need to delete the orders first.

DELETE FROM orders WHERE customer_id = 3
DELETE FROM customers WHERE id = 3;

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- Bob Brown calls you and claims that his order with order_id 6
-- arrived damaged. He wants to keep the order but wants a refund of 50% of the
-- total amount. Write the SQL DML statement to update the `total_amount` of
-- Bob Brown's order with order_id 6 to reflect the refund. Ensure that the
-- update is successful and the data is reflected in the `orders` table.
-- https://duckdb.org/docs/stable/sql/statements/update
--------------------------------------------------------------------------------
-- Solution:

UPDATE orders
SET total_amount = total_amount * 0.5
WHERE order_id = 6;

SELECT * FROM orders;  /* verify update*/
--------------------------------------------------------------------------------
