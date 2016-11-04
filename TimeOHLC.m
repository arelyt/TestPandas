%%
% *%%
% *%%Начинаем OHLC свечи
% %Функция для ресэмплинга по тикам и объему
function y = TimeOHLC(t, deltas, method)

tlen = height(t);  %Длина таблицы
da = [];
hi = [];
lo = [];
op = [];
cl = [];
vBuy =[];
vSell = [];
nBuy = [];
nSell =[];
dTime =[];
switch method
    case 'tick'
        temp = int64(tlen/deltas)-2;
        reserve_memory();
        
        for i = 1:temp
            if i < temp
                ss = deltas*(i);      % Левая граница выбора
                sd = deltas*(i+1);           % Правая граница выбора
            else
                ss = deltas*(i);
                sd = tlen;
            end
            resample_tick();
        end
        revert_for_table();
        
        
    case 'volume'
        temp = int64(t.AbsCumDelta(end)/deltas) - 2;
        reserve_memory();
        
        for j = 0:deltas:temp
            if j < temp
                ss = j;
                sd = j +deltas;
            else
                ss =  j;
                sd = t.AbsCumDelta(end);
            end
            i = j + 1;
            resample_volume();
        end
        revert_for_table();
        
        
end

    function reserve_memory()
        
        op = zeros(1, temp);
        hi = zeros(1, temp);
        lo = zeros(1, temp);
        cl = zeros(1, temp);
        vBuy = zeros(1, temp);
        vSell = zeros(1, temp);
        nBuy = zeros(1, temp);
        nSell = zeros(1, temp);
        dTime = seconds(zeros(1, temp));
        da = repmat(datetime(0, 0, 0, 0, 0, 0), 1, temp);
        
    end



    function resample_volume()
        rows = t.AbsCumDelta >ss & t.AbsCumDelta <= sd;
        vars = {'DateTime', 'Price', 'VolBuy', 'VolSell'};
        tt = t(rows, vars);
        da(i) = tt.DateTime(end);
        hi(i) = max(tt.Price);
        lo(i) = min(tt.Price);
        op(i) = tt.Price(1);
        cl(i) = tt.Price(end);
        vBuy(i) = sum(tt.VolBuy);
        vSell(i) = sum(tt.VolSell);
        nBuy(i) = sum(tt.VolBuy ~= 0);
        nSell(i) = sum(tt.VolSell ~= 0);
        dTime(i) = tt.DateTime(end) - tt.DateTime(1);
    end


    function resample_tick()
        da(i) = t.DateTime(sd, :);
        hi(i) = max(t.Price(ss:sd, :));
        lo(i) = min(t.Price(ss:sd, :));
        op(i) = t.Price(ss, :);
        cl(i) = t.Price(sd, :);
        vBuy(i) = sum(t.VolBuy(ss:sd, :));
        vSell(i) = sum(t.VolSell(ss:sd, :));
        nBuy(i) = sum(t.VolBuy(ss:sd, :) ~= 0);
        nSell(i) = sum(t.VolSell(ss:sd, :) ~= 0);
        dTime(i) = t.DateTime(sd) - t.DateTime(ss);
        
    end

    function revert_for_table()
        d = datenum(da');
        h = hi';
        l = lo';
        o = op';
        c = cl';
        vB = vBuy';
        vS = vSell';
        nB = nBuy';
        nS = nSell';
        dT = seconds(dTime)';
        TspeedBuy = nB./dT;
        TspeedSell = nS./dT;
        vto = (nB.*vB - nS.*vS)./(nB.*vB + nS.*vS);
    end

y = table(d, h, l, o, c, vB, vS, nB, nS, dT, TspeedBuy, TspeedSell, vto);
end
% candle(h, l, c, o);

