function downloadData(product, begins, ends)
if ~isfolder('./data')
    mkdir('data');
    addpath('./data');
end
if ~exist('begins', 'var')
    % January 1, 2000
    begins = 946684800;
end
if ~exist('ends', 'var')
    % December 31, 2021
    ends = 1640908800;
end
url = "https://query1.finance.yahoo.com/v7/finance/download/" ...
    + product + "?period1=" + string(begins) + "&period2=" + string(ends) ...
    + "&interval=1d&events=history&includeAdjustedClose=true";
filename = "./data/" + product + "_D1_RAW.csv";
options = weboptions('UserAgent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36');
try
    websave(filename, url, options);
catch
   fprintf("Unable to download. Please access: \n%s\n", url);
end
end

