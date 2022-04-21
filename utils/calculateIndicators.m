function outTb = calculateIndicators(product)
filename = product + "_D1_RAW.csv";
dataTimeTable = readtimetable(filename);
dataTimeTable = rmmissing(dataTimeTable);
n = size(dataTimeTable, 1);

% Timetable for Indicators
inidicatorNames = {'Return', 'Return5', 'Return20', 'SMA5', 'SMA20', ...
    'EMA5', 'EMA20', 'MACD', 'MACDSignal', 'RSI'};
indicatorTypes = repmat({'double'}, 1, length(inidicatorNames));
numIndicators = length(inidicatorNames);
inidicatorsTt = timetable('VariableNames', inidicatorNames, ...
                          'VariableTypes',indicatorTypes, ...
                          'RowTimes', dataTimeTable.Date, ...
                          'Size', [n, numIndicators]);

% ============ Calculate moving averages ============
sma5 = movavg(dataTimeTable, 'simple', 5);
sma20 = movavg(dataTimeTable, 'simple', 20);
ema5 = movavg(dataTimeTable, 'exponential', 5);
ema20 = movavg(dataTimeTable, 'exponential', 20);

% ================== Calculate MACD =================
[macdLine, macdSignalLine]= macd(dataTimeTable);

% ================== Calculate RSI ==================
% Set the temporary table's Close as the Open because rsindex
% only applies to the closing price
dataTimeTableMov = timetable('VariableNames', {'Close'}, ...
                             'VariableTypes', {'double'}, ...
                             'RowTimes', dataTimeTable.Date, ...
                             'Size', [n, 1]);
dataTimeTableMov{:, 'Close'} = dataTimeTable{:, 'Open'};
rsiIndex = rsindex(dataTimeTableMov, 'WindowSize', 14);

for i=2:n
    inidicatorsTt{i, 'Return'} = dataTimeTable{i, 'Open'} / dataTimeTable{i-1, 'Open'};
end
% Return5
for i=5:n
    inidicatorsTt{i, 'Return5'} = dataTimeTable{i, 'Open'} / dataTimeTable{i-4, 'Open'};
end
% Return20
for i=20:n
    inidicatorsTt{i, 'Return20'} = dataTimeTable{i, 'Open'} / dataTimeTable{i-19, 'Open'};
end
inidicatorsTt{5:end, 'SMA5'} = sma5{5:end, 'Open'};
inidicatorsTt{20:end, 'SMA20'} = sma20{20:end, 'Open'};
inidicatorsTt{5:end, 'EMA5'} = ema5{5:end, 'Open'};
inidicatorsTt{20:end, 'EMA20'} = ema20{20:end, 'Open'};
inidicatorsTt{26:end, 'MACD'} = macdLine{26:end, 'Open'};
inidicatorsTt{26:end, 'MACDSignal'} = macdSignalLine{26:end, 'Open'};
inidicatorsTt{14:end, 'RSI'} = rsiIndex{14:end, 1};

% For those calculations that shifting is not needed
inidicatorsTt{15:end, 'RSI'} = rsiIndex{14:end-1 ,1};

% Concat with the original timetable
outTt = [dataTimeTable, inidicatorsTt];

% Flip the table (just for code compatability issues)
outTt = flip(outTt);

% Save the timetable
writetimetable(outTt, "./data/" + product + "_D1.csv", 'DateLocale', 'en_US');
end

