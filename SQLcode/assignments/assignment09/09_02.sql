--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 09
-- Exercise 02
--------------------------------------------------------------------------------
-- In this exercise, we will work with the DuckDB database file `university.db`.
-- The database contains the following tables:
-- - `students`: Contains information about students (id, name, major, pursued_degree, age).
-- - `staff`: Contains information about staff members (id, name, department_id, age).
-- - `class`: Contains information about classes (id, name, meets_at, room, class_staff_id).
-- - `enrolled`: Contains information about which students are enrolled in which classes (student_id, class_id).
-- - `department`: Contains information about departments (id, name).
--------------------------------------------------------------------------------
-- Task (a) — [E]
--------------------------------------------------------------------------------
-- Please write a SQL query that returns the names of all students which names
-- begin with "Mar", and pursue a degree in "Bachelor of Science" ('B.Sc.').
--------------------------------------------------------------------------------
-- Solution:

SELECT student_name
FROM student
WHERE student_name LIKE 'Mar%'
  AND pursued_degree = 'B.Sc.';

--------------------------------------------------------------------------------
-- Task (b) — [E]
--------------------------------------------------------------------------------
-- Please write a SQL query that returns the name of each class and the name of the
-- staff member who teaches that class.
--------------------------------------------------------------------------------
-- Solution:

SELECT c.class_name, s.staff_name
FROM class c
JOIN staff s ON c.class_staff_id = s.staff_id;

--------------------------------------------------------------------------------
-- Task (c) — [E]
--------------------------------------------------------------------------------
-- Please list all students enrolled in classes of the "Computer Science" department.
-- The result should not contain duplicates. Do you need to use `DISTINCT`?
-- Please explain briefly why or why not.
--------------------------------------------------------------------------------
-- Solution:

SELECT DISTINCT st.student_name
FROM student st
JOIN enrolled e ON st.student_id = e.enrolled_student_id
JOIN class c ON e.enrolled_class_id = c.class_id
JOIN staff sf ON c.class_staff_id = sf.staff_id
JOIN department d ON sf.staff_department_id = d.department_id
WHERE d.department_name = 'Computer Science';


--------------------------------------------------------------------------------
-- Task (d) — [E]
--------------------------------------------------------------------------------
-- Please write a SQL query that finds the names of all students who are enrolled in classes
-- that are taught by "Ivana Teach".
--------------------------------------------------------------------------------
-- Solution:

SELECT DISTINCT st.student_name
FROM student st
JOIN enrolled e ON st.student_id = e.enrolled_student_id
JOIN class c ON e.enrolled_class_id = c.class_id
JOIN staff sf ON c.class_staff_id = sf.staff_id
WHERE sf.staff_name = 'Ivana Teach';


--------------------------------------------------------------------------------
-- Task (e) — [E]
--------------------------------------------------------------------------------
-- Please write a SQL query that returns the names of all staff members, who
-- are at least twice as old as some student enrolled in one of their classes.
--------------------------------------------------------------------------------
-- Solution:

SELECT DISTINCT sf.staff_name
FROM staff sf
JOIN class c ON sf.staff_id = c.class_staff_id
JOIN enrolled e ON c.class_id = e.enrolled_class_id
JOIN student st ON e.enrolled_student_id = st.student_id
WHERE sf.age >= 2 * st.age;


--------------------------------------------------------------------------------
-- Task (f) — [E]
--------------------------------------------------------------------------------
-- Please write a SQL query that returns classes that have both 'B.Sc.' and 'M.Sc.'
-- students enrolled.
--------------------------------------------------------------------------------
-- Solution:

SELECT c.class_name
FROM class c
JOIN enrolled e ON c.class_id = e.enrolled_class_id
JOIN student st ON e.enrolled_student_id = st.student_id
GROUP BY c.class_id, c.class_name
HAVING 
    SUM(CASE WHEN st.pursued_degree = 'B.Sc.' THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN st.pursued_degree = 'M.Sc.' THEN 1 ELSE 0 END) > 0;


--------------------------------------------------------------------------------
-- Task (g)
--------------------------------------------------------------------------------
-- Please write a SQL query that for each class, lists the class name,
-- the name of the staff member teaching that class, and the name of the department
-- the staff member belongs to. Careful: The staff member may not belong to a department.
-- Note: The solution requires a FULL OUTER JOIN.
--------------------------------------------------------------------------------
-- Solution:

SELECT 
    c.class_name,
    sf.staff_name,
    d.department_name
FROM class c
JOIN staff sf ON c.class_staff_id = sf.staff_id
LEFT JOIN department d ON sf.staff_department_id = d.department_id;

--------------------------------------------------------------------------------
