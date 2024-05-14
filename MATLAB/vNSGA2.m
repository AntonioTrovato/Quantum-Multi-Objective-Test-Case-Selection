%for each program
%costs is an array of size N
%coverage is an array of size N
%revealed_failures is an array of size N (of binary values)

function f = fitnessFunction(x, costs, coverage, revealed_failures)
    % Objective 1: Minimize the execution cost
    total_cost = sum(x .* costs)/sum(costs);
    
    % Objective 2: Maximize the statement coverage (converted to minimization)
    selected_lines = [];
    for i = 1:length(coverage)
        if x(i) == 1
            selected_lines = [selected_lines, coverage{i}];
        end
    end
    unique_covered_lines = unique(selected_lines);
    total_coverage = -length(unique_covered_lines) / 5311;
    
    % Objective 3: Maximize the number of revealed failures (converted to minimization)
    nonzero_failures = revealed_failures(revealed_failures ~= 0);  % Filter out the zeros
    total_failures = -sum(x .* revealed_failures)/length(nonzero_failures);
    
    f = [total_cost, total_coverage, total_failures];
end

% Parameters
N = 806;  % Number of test cases (example value)
M = 200;  % Population size (example value)

% Example data for test cases

%get costs
data = fileread('grep_costs.txt');
costs = str2double(strsplit(data, ','));


% Read the content of the text file
fileID = fopen('grep_coverage.txt', 'r');
rawData = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);
% Initialize the coverage cell array
coverage = cell(length(rawData{1}), 1);
% Parse each line and convert it to a numeric array
for i = 1:length(rawData{1})
    % Split the string by commas
    strArray = strsplit(rawData{1}{i}, ',');
    % Convert the string array to a numeric array
    coverage{i} = str2double(strArray);
end


%get revealed_failures
data = fileread('grep_revealed_failures.txt');
revealed_failures = str2double(strsplit(data, ','));

% Define the fitness function handle
fitnessFcn = @(x) fitnessFunction(x, costs, coverage, revealed_failures);

% Define the number of variables (binary decision for each test case)
nvars = N;

% Define the bounds and constraints
lb = zeros(1, nvars);  % Lower bound (not selected)
ub = ones(1, nvars);   % Upper bound (selected)
IntCon = 1:nvars;      % Indicate that all variables are integer

% Define options for gamultiobj
options = optimoptions('gamultiobj', ...
    'PopulationSize', M, ...
    'MaxGenerations', 1000, ...
    'CrossoverFcn', {@crossoverscattered}, ...
    'MutationFcn', {@mutationuniform, 1/N}, ...
    'FunctionTolerance', 0.05, ...
    'MaxStallGenerations', 50, ...
    'MigrationInterval', 20, ...
    'Display', 'iter', ...
    'DistanceMeasureFcn', {@distancecrowding,'phenotype'});

% Array to store Pareto fronts
pareto_fronts = cell(1, 10);

% Array to store execution times
execution_times = zeros(1, 10);

% Repeat the optimization process 10 times
for i = 1:10
    fprintf('Optimization iteration %d\n', i);
    % Start timing
    tic;
    % Run gamultiobj
    [x, fval, exitflag, output, population, scores] = gamultiobj(fitnessFcn, nvars, [], [], [], [], lb, ub, [], IntCon, options);

    % Stop timing and save execution time
    execution_times(i) = toc * 1000;  % Convert time to milliseconds

    % Initialize front array
    pareto_front = cell(size(x, 1), 1);

    % Iterate over each row of x
    for row = 1:size(x, 1)
        % Find the indices where x(row, :) is equal to 1
        indices = find(x(row, :) == 1);
        % Subtract 1 from each index to start from 0
        indices = indices - 1;
        % Store the indices in the corresponding row of front
        pareto_front{row} = indices;
    end

    % Store Pareto front
    pareto_fronts{i} = pareto_front;
end

% Calculate mean execution time
mean_execution_time = mean(execution_times);

% Display mean execution time
fprintf('vNSGA-II mean execution time (ms): %f\n', mean_execution_time);

% Save Pareto fronts and mean execution time to JSON file
json_data = struct();
for i = 1:10
    field_name = sprintf('grep_pareto_front_%d', i-1);
    json_data.(field_name) = pareto_fronts{i};
end
json_data.vNSGA_II_mean_execution_time_ms = mean_execution_time;

json_file = 'grep_pareto_fronts.json';
json_str = jsonencode(json_data);
fid = fopen(json_file, 'w');
fprintf(fid, '%s', json_str);
fclose(fid);

disp('JSON file saved successfully.');
