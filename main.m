%% Section 1: Importing Dependencies and Data
% Add the genetic programming module to MATLAB path
addpath(genpath('./gp'));

% Add the utils path to MATLAB path
addpath('./utils');

% Add the data path
if ~isfolder('./data')
    mkdir('data');
end
addpath('./data');

%% Section 2: Data Preprocessing
% Define the product
% For the correct product name, visit: https://finance.yahoo.com/
product = '^DJI';
filename = "./data/" + product + "_D1.csv";

% Download data from the Yahoo Finance (if not exists)
if ~isfile(filename)
    downloadData(product);
    
    % Calculate the indicators (speedup training)
    % NOTE: You must have the financial toolbox installed.
    calculateIndicators(product);
end

% Use a random seed
rng shuffle

% Read the data
data = readtable(filename);

% Define the transaction cost in the form of Ask and Bid
commission = 0.0025;  % A transaction cost of 0.25%
data.Ask = data{:, 'Open'} / (1 - commission);
data.Bid = data{:, 'Open'};

% Split the data into training and test set
% Testing period: 2020 - 2021 (2 years)
[splitMonth, splitDay, splitYear] = deal(1, 1, 2020);
[testSet, trainingSet, trainBeginIdx] = splitDataByDate(data, ...
    splitYear, splitMonth, splitDay);

% Training period: 2010 - 2019 (10 years)
[splitMonth, splitDay, splitYear] = deal(1, 1, 2010);
try
    [trainingSet, ~, ~] = splitDataByDate(trainingSet, ...
        splitYear, splitMonth, splitDay);
catch
end
    
%% Section 3: Define the template for GP
template = Template();
template.set("Root", { ...
    IfThenElse(), ...
    });
% We can set the lower and upper bound to the same value. This ensures the
% right-hand side of such Variable will not contain a value.
template.set("Operator.BinaryOperator.BinaryRelationalOperator.lhs", { ...
    Variable("RSI", 'bounded', 'double', 0, 100), ...
    Variable("EMA5", 'none', 'double'), ...
    Variable("EMA20", 'none', 'double'), ...
    Variable("MACD", 'bounded', 'double', 0, 0), ...
    Variable("MACDSignal", 'none', 'double'), ...
    Variable("Bid", 'none', 'double'), ...
    Variable("Return5", 'bounded', 'double', ...
                min(trainingSet{:, 'Return5'}), max(trainingSet{:, 'Return5'})), ...
    Variable("Return20", 'bounded', 'double', ...
                min(trainingSet{:, 'Return20'}), max(trainingSet{:, 'Return20'})), ...
    });
% We can place more prototypes of a certain type to increase the
% probability of it being chosen.
% Values only appear on the right-hand side.
template.set("Operator.BinaryOperator.BinaryRelationalOperator.rhs", { ...
    Value(), Value(), Value(), Value(), Value(), Value(), ...
    Variable("EMA5", 'none', 'double'), ...
    Variable("EMA20", 'none', 'double'), ...
    Variable("MACD", 'bounded', 'double', 0, 0), ...
    Variable("MACDSignal", 'none', 'double'), ...
    });
template.set("Operator.BinaryOperator.BinaryLogicalOperator.lhs", { ...
    GreaterEqual(), LessEqual(), And(), Or()...
    });
template.set("Operator.BinaryOperator.BinaryLogicalOperator.rhs", { ...
    GreaterEqual(), LessEqual(), And(), Or() ...
    });
template.set("Statement.IfThenElse.ifNode", { ...
    GreaterEqual(), LessEqual(), And(), Or() ...
    });
% 1 for sell, 2 for hold, and 3 for buy
template.set("Statement.IfThenElse.thenNode", { ...
    IfThenElse(), IfThenElse(), EnumeratedSignal({1, 2, 3})});
template.set("Statement.IfThenElse.elseNode", { ...
    IfThenElse(), IfThenElse(), EnumeratedSignal({1, 2, 3})});

%% Section 4: Define the parameters for GP
% Note: The parameters are not optimized.
opt.populationSize = 25;
opt.maxHeight = 6;
opt.generations = 20;
opt.selectionSchema = 'tournament';
opt.tournamentSize = 3;
opt.eliteSize = 8;
opt.crossoverFraction = 0.8;
opt.mutateAfterCrossover = true;
opt.reevaluateElites = false;
opt.mutationProb = 0.05;
opt.terminalMutationProb = 0.15;

%% Section 5: Setup and optimize the GP Model
% Instantiate the GP model
myGPModel = MyGPModel();

% Register the options
myGPModel.register(opt);

% Populate the GPModel with individuals
% GPModel's `populate` will call the constructor specified
myGPModel.populate();

% Initialize every individual in the population
myGPModel.init(template, opt.maxHeight);

% Optimize the model using genetic algorithm
tic;
myGPModel.run(trainingSet);
toc;

%% Section 6: Evaluation
% Show the best performing strategy in pseudocode
myGPModel.pseudocode(1);

% Test the strategy on the test set
r = backtest(myGPModel.best, testSet);
fprintf("Return on test set: %s\n", string(r));
