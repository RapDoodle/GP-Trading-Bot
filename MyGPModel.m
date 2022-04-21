classdef MyGPModel < GPModel
    
    properties
        trainingSet
        baseline
    end
    
    methods
        function model = MyGPModel()
            model = model@GPModel(@GPMember);
        end
        
        function beforeRun(model, varargin)
            baselineRoot = getBuyAndHoldGP();
            model.baseline = backtest(baselineRoot, ...
                varargin{1});
            fprintf("Buy-and-hold strategy on training set: %f\n", model.baseline);
        end
        
        function forEachGeneration(model, gen, gens, varargin)
            % Localize variables to avoid unnessary communication overhead
            n = model.populationSize;
            
            % Retrieve the vairables initially provided when calling the 
            % run method.
            data = varargin{1};
            
            % Spread out the variable to avoid communication overhead when
            % using parallel computing toolbox
            population = model.population;
            
            % Execute using MATLAB's parallel computing toolbox. If you do
            % not have the license for it, replace `parfor` with `for`.
            parfor s=1:n
                fitness = 0;
                r = backtest(population{s}, data);
                
                fprintf("[Generation %d] Strategy %d return: %s\n", ...
                    gen, s, string(r));
                
                fitnesses(s) = r;
            end
            
            fitnesses = model.sortPopulation(fitnesses);
            model.statistics.minFitnesses(gen) = fitnesses(end);
            model.statistics.maxFitnesses(gen) = fitnesses(1);
            
            model.naturalSelection();
            model.reproduction(fitnesses);
        end
    end
end

