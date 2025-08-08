--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 02
-- Exercise 03
--------------------------------------------------------------------------------

-- Tables can be used to store basically arbitrary data. In the lecture, we
-- discussed how a state machine can be represented as tables. In this
-- exercise, we will represent a directed graph using a table:

CREATE TABLE nodes (
    id INTEGER NOT NULL PRIMARY KEY
);

CREATE TABLE edges (
    source INTEGER NOT NULL REFERENCES nodes(id),
    target INTEGER NOT NULL REFERENCES nodes(id),
    PRIMARY KEY (source, target)
);

-- The tables contain the following data:
INSERT INTO nodes (id) VALUES
    (1),
    (2),
    (3),
    (4),
    (5);

INSERT INTO edges (source, target) VALUES
    (1, 2),
    (1, 3),
    (3, 4),
    (4, 5);

-- The graph can be visualized as follows:
-- 1 → 2
-- ↓
-- 3 → 4 → 5

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Why would it be a bad idea to use a single table to store the graph? What are
-- the advantages of using two tables?
-- CREATE TABLE graph (
--     id INTEGER NOT NULL PRIMARY KEY,
--     source INTEGER NOT NULL REFERENCES graph(id),
--     target INTEGER NOT NULL REFERENCES graph(id)
-- );
--------------------------------------------------------------------------------
-- Solution:

-- Yes, it would be a bad idea to use a single table. This is because using two
-- tables would allow us to use foreign key constraints to enforce
-- the graph structure and make sure that each edge is only build on already
-- existing nodes. If the nodes would not already exist in the nodes table,
-- the duckDB system would not allow us to reference this unexisting node in the
-- edges table. This would not be possible if we used a single table, as the
-- foreign key constraints would not be able to enforce the graph structure.
--
-- Also using two tables separates the entities which
-- follows database principle, and would allow us to simply extend the graph
-- with additional node/edge attributes in the future if needed.

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- We want to delete the node with id 3 from the graph, without
-- deleting nodes 4 and 5. This will effectively split the graph into two
-- disconnected components. Write the SQL DML statement to delete the node
-- with id 3 from the graph. Remember that you have to delete the
-- corresponding edges before you can delete the node.

--------------------------------------------------------------------------------
-- Solution:

-- Delete edges connected to node 3
DELETE FROM edges WHERE source = 3 OR target = 3;
-- Delete the node 
DELETE FROM nodes WHERE id = 3;

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Write the SQL DML statement to add a new node with id 6 to the graph.
-- Please add edges from node 1 to node 6 and from node 6 to node 5.
-- Also add an edge from node 5 to node 6.
--------------------------------------------------------------------------------
-- Solution:

-- Add new node
INSERT INTO nodes (id) VALUES (6);
-- Add new edges 
INSERT INTO edges (source, target) VALUES 
    (1, 6),
    (6, 5),
    (5, 6);

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- The graph is now cyclic. Please explain why this is not a problem in the
-- context of the graph representation we are using.
--------------------------------------------------------------------------------
-- Solution:

-- Because the database treats edges as independent records, and sql queries 
-- also process edges as discrete records rather than traversing paths,
-- so presence of cycles would not cause infinite loops. Therefore, a cyclic 
-- graph would not be a problem.

-- Since foreign key constraints only ensure referential integrity and do 
-- not imply directional or acyclic traversal, the presence of a cycle 
-- (e.g., 5 → 6 → 5) does not violate any database constraint nor cause
--  unintended behavior during basic SQL operations like 
-- SELECT, INSERT, or DELETE.

-- The graph is just stored as static structure without any traversal logic!
-- Hence, the graph can be cyclic without causing any issues.

--------------------------------------------------------------------------------
-- Task (e)
--------------------------------------------------------------------------------
-- We now need to add text labels to the edges of the graph.
-- Propose a design for a new table labels that holds such edge labels.
-- Leave the existing tables intact. Make sure to add appropriate primary and
-- foreign keys to table labels.
--
-- Once you have created table `labels`, attach label 'X' to edge 5->6
-- and label 'Y' to edge 6->5 using SQL DML statements.
--------------------------------------------------------------------------------
-- Solution:

-- Create edge labels table
CREATE TABLE labels (
    source INTEGER NOT NULL,
    target INTEGER NOT NULL,
    label TEXT NOT NULL,
    PRIMARY KEY (source, target),
    FOREIGN KEY (source, target) REFERENCES edges(source, target)
);
-- Add labels to specific edges
INSERT INTO labels (source, target, label) VALUES 
    (5, 6, 'X'),
    (6, 5, 'Y');

--------------------------------------------------------------------------------