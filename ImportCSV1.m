%% Import data from text file.
function [w] = ImportCSV1(fname)
% Script for importing data from the following text file:
%
%    /Users/AreVa/PycharmProjects/TestPandas/tick.csv

%% Initialize variables.
filename = 'RIM6_4.csv';
delimiter = ',';
startRow = 2;

%% Format for each line of text:
%   column2: datetimes (%{yyyy-MM-dd HH:mm:ss}D)
%	column3: double (%f)
%   and so on
% For more information, see the TEXTSCAN documentation.
formatSpec = '%{yyyyMMdd}D%{HHmmss}D%f%f%f%f%s%f%f%f%f%f%f%[^\n\r]';
%formatSpec = '%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
%
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,...
                            'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
%
fclose(fileID);
%% Names of fields
%
Date      = dataArray{:,1};
Time      = dataArray{:,2};
Ms        = dataArray{:,3};
TradeNo   = dataArray{:,4};
Price     = dataArray{:,5};
Vol       = dataArray{:,6};
Dir       = dataArray{:,7};
Ask       = dataArray{:,8};
AskQty    = dataArray{:,9};
Bid       = dataArray{:,10};
BidQty    = dataArray{:,11};
Oi        = dataArray{:,12};
StepPrice = dataArray{:,13};

%% Postimport processing
%
DateTime = Date + timeofday(Time) + milliseconds(Ms);
%VolBuy = Vol(Dir=='Buy');

%% Return table
%
w = table(DateTime, TradeNo, Price, Vol, Dir, Ask, AskQty, Bid, BidQty, Oi, StepPrice);
w.VolBuy  = zeros(height(w),1);
w.VolSell = zeros(height(w),1);
w.VolBuy(w.Dir==string('Buy'))=w.Vol(w.Dir==string('Buy'));
w.VolSell(w.Dir==string('Sell'))=w.Vol(w.Dir==string('Sell'));
w.DateTime.Format = 'yyyy-MM-dd HH:mm:ss.SSS';
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
end

