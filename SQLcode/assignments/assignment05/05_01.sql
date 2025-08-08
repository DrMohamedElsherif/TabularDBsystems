--------------------------------------------------------------------------------
-- Tabular Database Systems
-- Assignment 05
-- Exercise 01
--------------------------------------------------------------------------------
-- In this exercise, we will implement the same query as in assignment 04,
-- but this time we will use the C language with mmap and threads to
-- speed up the query processing.
-- The query is: "Compute the minimum integer value in the 5th column —
-- consider only rows whose integer value in the first column is less than 2000000".
-- Please download the TPC-H table `lineitem` from the following URL:
-- https://db.cs.uni-tuebingen.de/staticfiles/lineitem.csv
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please implement the query using mmap and threads in C.
-- See file 018-sum-quantity-mmap-threads.c in the lecture material for
-- an example C source file.
--------------------------------------------------------------------------------
-- Solution:
-- Please hand in a file query_mmap_threads.c that contains the solution.
--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- How does the run time performance of your solution in (a) vary
-- with the number of threads (see variable T in the original C source)
-- your program spawns?  How does T = 1 perform?  How does T = 128 perform?
-- Where is the "sweet spot" for T in your implementation on your
-- computer?
--------------------------------------------------------------------------------
-- Solution:

- We experimented with values from 1 to 128, using intervals of 2 up to T = 50, then intervals of 5 from T = 50 to T = 100, and finally at T = 110 and T = 128.

-- At T=1, we observe baseline sequential performance with a runtime of approximately 1.00 second and 100% efficiency, which closely 
-- matches Assignment 04's results (see tsv table in outputfiles/exercise01 folder). This expected behavior occurs because 
-- the task executes entirely on a single core, and there is no parallelization overhead.

-- As we increase the thread count to T=8, we achieve approximately a 6.67× speedup (reducing runtime to 0.12 seconds) 
-- while maintaining 83.3% efficiency, indicating near-optimal scaling. This strong performance demonstrates that the workload divides 
-- effectively across threads and aligns well with my Mac Pro M2 chip's architecture - specifically its 4 high-performance cores (P-cores) and 
-- 4 efficiency cores (E-cores) - along with its memory architecture (24GB RAM with ~100GB/s bandwidth as reported by Apple). These hardware characteristics 
-- appear sufficient to maintain high efficiency (>80%) up to this thread count (see plots in outputfiles/exercise01 folder).

-- Beyond T=12, we observe the speedup plateauing at around 8.89× while efficiency drops sharply below 50%. This phenomenon reflects two 
-- fundamental limitations: first, Amdahl's Law, which states that maximum parallelization speed is constrained by the non-parallelizable
-- portions of the task (such as sequntial code, thread coordination and memory access); and second, my hardware constraints, including the 
-- relatively modest core count, limited memory bandwidth, and lack of advanced overhead management techniques like atomics.*(see footnote)

-- At T = 128, we observe that the speedup remains capped at 10× with a runtime of 0.08 seconds, but efficiency drops far low down to just 7.81%. 
-- This indicates severe diminishing returns due to the overhead of managing a large number of threads exceeding the Mac Pro M2 hardware parallelism capabilities. 
-- The low efficiency reflects that most threads spend time waiting or coordinating rather than doing the task itself. 

-- Therefore, we conclude that the optimal operating range lies between T=8 and T=12, where we achieve the best balance between speed and 
-- efficiency. While T=36 does offer the fastest runtime of 0.07 seconds (11.43× speedup), its significantly reduced efficiency of 31.7% makes 
-- it impractical for sustained workloads. Consequently, T=8-12 apeears as the ideal configuration fro this task, as it maximizes performance 
-- per thread while minimizing overhead.

-- If you still however require us to choose only one sweet/sweetest value for T (for this exercise and the used hardware), then it would be T=10, 
-- because it offers 8× speedup (0.10s) at 80% efficiency—20% faster than T=8 with minimal overhead, while avoiding T=12’s slightly lower
-- efficiency. 


-- *References of scientific argument are: 
-- Foundation knowledge from 'Programming in C/C++' WS23, and 'Massive Parallel Processing' WS24/25 courses by Prof Dr. Ing. Hendrich Lensch.

--------------------------------------------------------------------------------
