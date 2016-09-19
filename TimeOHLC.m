%%
% *%%
% *%%Начинаем OHLC свечи
% %Функция для ресэмплинга по Дельте**
function y = TimeOHLC(table, deltas)
x = table.AbsCumDelta(1:deltas:end);
y = table.Price(1:deltas:end);

%Цикл по OHLC
op = zeros(1, int64(max(table.AbsCumDelta)/deltas));
hi = zeros(1, int64(max(table.AbsCumDelta)/deltas));
lo = zeros(1, int64(max(table.AbsCumDelta)/deltas));
cl = zeros(1, int64(max(table.AbsCumDelta)/deltas));
da = repmat(datetime(0, 0, 0, 0, 0, 0), 1, int64(max(table.AbsCumDelta)/deltas));

for i = 1:int64(max(table.AbsCumDelta)/deltas)
    ss = (i-1)*deltas;      % Левая граница выбора
    sd = deltas*i;           % Правая граница выбора
    t = table.Price(table.AbsCumDelta>=ss & table.AbsCumDelta<sd);
    da(i) = max(table.DateTime(table.AbsCumDelta>=ss & table.AbsCumDelta<sd));
    hi(i) = max(t);
    lo(i) = min(t);
    op(i) = t(1);
    cl(i) = t(end);
end
    d = datenum(da');
    h = hi';
    l = lo';
    o = op';
    c = cl';
    x1 = 1:int64(max(table.AbsCumDelta)/deltas);

candle(h, l, c, o);

