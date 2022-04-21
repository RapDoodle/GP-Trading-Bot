function [set1, set2, i] = splitDataByDate(data, yy, mm, dd)
% NOTE: The function assumes the data are sorted in descending order
%   (the most recent day comes first)
% i is the split point (the index in which set2 begins)
n = size(data, 1);
inRange = true;
if ismember('Date', data.Properties.VariableNames)
    for i=1:n
        cy = year(data{i, 'Date'});
        cm = month(data{i, 'Date'});
        cd = day(data{i, 'Date'});
        if cy ~= yy
            inRange = cy >= yy;
        elseif cm ~= mm
            inRange = cm >= mm;
        elseif cd ~= dd
            inRange = cd >= dd;
        end

        if ~inRange
            break;
        end
    end
else
    % Alternative routine for data consisting of Year, Month, and Day
    % spread across three columns.
    for i=1:n
        if data{i, 'Year'} ~= yy
            inRange = data{i, 'Year'} >= yy;
        elseif data{i, 'Month'} ~= mm
            inRange = data{i, 'Month'} >= mm;
        elseif data{i, 'Day'} ~= dd
            inRange = data{i, 'Day'} >= dd;
        end

        if ~inRange
            break;
        end
    end
end

if ~inRange
    set1 = data(1:i-1, :);
    set2 = data(i:end, :);
else
    error('Unknown split point.');
end
end

