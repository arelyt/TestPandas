%%
% *%%
% *%%Начинаем OHLC свечи
% %Функция для ресэмплинга по Дельте**
function y = TimeOHLC(t, deltas, method)

tlen = height(t);  %Длина таблицы

temp = int64(tlen/deltas)-2;
if method == 'tick' 

        %Цикл по OHLC
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

        for i = 1:temp
            if i < temp
                ss = deltas*(i);      % Левая граница выбора
                sd = deltas*(i+1);           % Правая граница выбора
            else
                ss = deltas*(i);
                sd = tlen;
            end
            
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
            
            y = table(d, h, l, o, c, vB, vS, nB, nS, dT, TspeedBuy, TspeedSell, vto);
            
            
end


% candle(h, l, c, o);

