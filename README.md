# SelectQA - Quantum Regression Test Case Selection
This repository contains all the necessary resources to reproduce the results of the 
SelectQA method.

## Dataset Files

### SIR Programs

The "./SIR_Programs" folder contains, for each SIR program considered by this project, 
all the files needed to gather statement coverage, execution costs, and past fault 
coverage information.

Let's take the "flex" program as an example.

Inside the folder "./SIR_Program/flex" the file "fault-matrix.txt" contains many rows 
as flex's test cases. Each row is divided by (in this case) 5 columns, representing 5 
different versions of the program. Each cell (i,j) contains a binary (0 or 1) value, 
representing the ability of the i-th test case to spot a fault in the j-th version 
of the program. This configuration is called fault matrix and is the resource needed 
to gain historical fault coverage information.

The folder "./SIR_Programs/flex/json_flex" contains a folder for each test case. The 
generic "ti" folder (i.e. the folder related to the i-th test case of flex) contains 
the "flexi.gcov.json" file. This JSON file is fundamental to recovering statement 
coverage and execution costs information since it tells us for each basic block of 
the system under test if the i-th test case did execute/cover it and how many times
the i-th test case executed it. This way, we can derive the total statement coverage 
and execution cost of a single test case.

### BootQA Datasets

The "./BootQA" folder contains, for each dataset used to compare SelectQA and 
BootQA, all the files needed to gather execution costs and failure rate information.

Let's use gsdtsr as an example.

The folder "./BootQA/gsdtsr" contains the file "gdtsr.csv" dataset file. This 
file contains, except for the first, many rows as test cases. Each row is then 
divided by three columns: id, time, and rate.

Also, "./BootQA/gsdtsr" contains the "sum.csv" file, which reports all the 
information gathered during the experiment executions to make statistical 
comparisons with other methods.

## Source Code Files

### MOQ-Pipeline.ipynb

This file contains three main algorithms:

- Additional Greedy;
- The three-objectives version of SelectQA;
- The two-objectives version of SelectQA.

This file implements all the pipelines necessary to run the algorithms, from the dataset 
information gathering, to algorithm execution and finally to empirical comparisons.

This file could be divided in two main sections.

#### SelectQA and Classical Algorithms

In the first section, the pipelines start from the analysis of SIR programs and end
with empirical comparisons between SelectQA and its classical counterparts.
Please, note that, while the dataset analysis and algorithms execution are generalized 
and automatically executable, the empirical evaluation part must be manually 
configured each time we change the target program. Also, once the target program has been 
manually changed, be sure to manually configure the different frontiers to correctly 
build the reference one.

#### SelectQA and BootQA

The second section contains the pipeline to read the datasets and run SelectQA. This 
section is completely generalized and automated, so there is no need for manual 
configurations.

The files that contain the execution of BootQA and the empirical evaluations between 
SelectQA and BootQA are different and its description follows.

### bootqa.py

This file, contained in the "./BootQA" folder, is a modified version of the original bootqa file from the GitHub 
repository hosting BootQA. It can be run without manual configurations to execute 
the annealing and store the results for statistical analysis.

### stats.py

This file, contained in the "./BootQA" folder, executes the empirical comparisons between SelectQA and BootQA, and it is not 
necessary to configure it. The final results are stored.

### DIVGA.m

The file "./MATLAB/DIVGA.m" contains the whole pipeline needed for the execution of 
the DIVGA algorithm. For simplicity, the statement coverage, execution costs, and fault 
coverage information already gathered by "./MOQ-Pipeline.ipynb" has been written into 
.txt files. This way, DIVGA.m just has to read the files to obtain that information, 
bypassing the actual datasets. 

Please, note that DIVGA.m is configured to run against one program at a time, so you 
will have to reconfigure the target and the algorithm parameters each time you 
change the target program. Also, be sure to reconfigure both the M, N and gamultiobj 
routine's parameters (the correct values are described in the paper by Panichella et 
al. named "Improving Multi-Objective Test Case Selection by Injecting Diversity in Genetic Algorithms").
In line 53, the denominator of total_coverage = -length(unique_covered_lines) / 2034; 
must be changed with the total number of code lines of the target program.
Be careful to change also the target files for results reporting.

## Results Files

The results files contain all the pareto frontiers and average execution times obtained 
by DIV-GA, Additional Greedy, and SelectQA after all the experiment executions.
These files are needed to make all the empirical evaluations and comparisons between 
the three methods. The results files are in the "./results" folder and are 
divided by algorithm.

The result of the executions of BootQA and the two-objective version of SelectQA are 
stored respectively as "sum_bootqa.csv" and "sum.csv". The results are in the 
"./BootQA" folder and divided by the correspondent dataset. Finally, in the same folder 
is stored the "stats_results.csv" file too, that contains the final results of the 
statistical analysis.
