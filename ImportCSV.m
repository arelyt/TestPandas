%% Import data from text file.
function [w] = ImportCSV(fname)
% Script for importing data from the following text file:
%
%    /Users/AreVa/PycharmProjects/TestPandas/tick.csv

%% Initialize variables.
filename = 'tick.csv';
delimiter = ',';
startRow = 2;

%% Format for each line of text:
%   column2: datetimes (%{yyyy-MM-dd HH:mm:ss}D)
%	column3: double (%f)
%   column4: double (%f)
%	column5: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%{yyyy-MM-dd HH:mm:ss}D%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
%
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,...
                            'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
DateTime = dataArray{:, 1};
Price = dataArray{:, 2};
VolBuy = dataArray{:, 3};
VolSell = dataArray{:, 4};
Delta = VolBuy - VolSell;
CumDelta = cumsum(Delta);
AbsCumDelta = cumsum(abs(Delta));

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% DateTime=datenum(DateTime);
%% Create table from variable
w = table(DateTime, Price, VolBuy, VolSell, Delta, CumDelta, AbsCumDelta);

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
end
