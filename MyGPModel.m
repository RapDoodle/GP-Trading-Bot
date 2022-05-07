classdef MyGPModel < GPModel
    
    properties
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
        
        function fitnesses = evaluateFitness(model, varargin)
            % Localize variables to avoid unnessary communication overhead.
            % Skip this step if you do not use parallel computing toolbox.
            n = model.options.populationSize;
            
            % Retrieve the vairables initially provided when calling the 
            % run method.
            data = varargin{1};
            
            % Spread out the variable to avoid communication overhead when
            % using parallel computing toolbox
            population = model.population;
            
            fitnesses = zeros(n, 1);
            
            % Get status information from the model's status struct
            gen = model.status.generation;
            % Execute using MATLAB's parallel computing toolbox. If you do
            % not have the license for it, replace `parfor` with `for`.
            parfor s=1:n
                r = backtest(population{s}, data);
                
                fprintf("[Generation %d] Strategy %d return: %s\n", ...
                    gen, s, string(r));
                
                fitnesses(s) = r;
            end
        end
    end
end

