%%
% *%%
% *%%Начинаем OHLC свечи
% %Функция для ресэмплинга по Дельте**
function y = TimeOHLC(table, deltas)
x = table.AbsCumDelta(1:deltas:end);
y = table.Price(1:deltas:end);

%Цикл по OHLC
opn = zeros(1, int64(max(table.AbsCumDelta)/deltas));
high = zeros(1, int64(max(table.AbsCumDelta)/deltas));
low = zeros(1, int64(max(table.AbsCumDelta)/deltas));
close = zeros(1, int64(max(table.AbsCumDelta)/deltas));

for i = 1:int64(max(table.AbsCumDelta)/deltas)
    ss = (i-1)*deltas;      % Левая граница выбора
    sd = deltas*i;           % Правая граница выбора
    hi(i) = max(table.Price(table.AbsCumDelta>=ss & table.AbsCumDelta<sd));
    lo(i) = min(table.Price(table.AbsCumDelta>=ss & table.AbsCumDelta<sd));
    op(i) = find(table.Price(table.AbsCumDelta>=ss & table.AbsCumDelta<sd), table.Price, 'first');
    cl(i) = find(table.Price(table.AbsCumDelta>=ss & table.AbsCumDelta<sd), table.Price, 'last');
end
x1 = 1:int64(max(table.AbsCumDelta)/deltas);
plot(x1, opn);