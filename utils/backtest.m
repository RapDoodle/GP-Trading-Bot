function r = backtest(strategy, data)
initialFund = 10000;
beginIdx = size(data, 1);
endIdx = 1;
units = 0;
balance = initialFund;
bought = false;

for i=beginIdx:-1:endIdx
    % Prepare the env object to be executed
    env = table2struct(data(i, :));
    
    % Execute the strategy to retrieve the daily trading signal
    signal = strategy.exec(env);

    if signal == 3
        % Singal to buy
        if ~bought
            % Use Ask to buy
            buy(env.Ask);
        end
    elseif signal == 1
        % Singal to sell
        if bought
            % Use Bid to sell
            sell(env.Bid);
        end
    end
end

r = (balance + units * env.Bid) / initialFund;

function buy(price)
    % Use Ask to buy
    units = units + (balance / price);
    balance = balance - balance;
    bought = true;
end

function sell(price)
    balance = balance + units * price;
    units = units - units;
    bought = false;
end
end

