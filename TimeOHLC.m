%%
% *%%
% *%%Начинаем OHLC свечи
% %Функция для ресэмплинга по тикам и объему
function y = TimeOHLC(t, deltas, method)

tlen = height(t);  %Длина таблицы
DateTime = [];
da = [];
hi= [];
lo = [];
op = [];
cl = [];
high = [];
low = [];
close = [];
open = [];
vBuy =[];
vSell = [];
nBuy = [];
nSell =[];
dTime =[];
vB = [];
vS = [];
nB = [];
nS = [];
dT = [];
TspeedBuy =[];
TspeedSell = [];
TsBuy = [];
TsSell = [];
vto = [];
VTO = [];
switch method
    case 'tick'
        sw = 0;
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
        sw = 0;
        temp = int64(t.AbsCumDelta(end)/deltas) - 2;
        reserve_memory();
        i = 1;
        for j = 0:deltas:temp*deltas
            if j < temp*deltas
                ss = j;
                sd = j +deltas;
            else
                ss =  j;
                sd = t.AbsCumDelta(end);
            end
            rows = t.AbsCumDelta >ss & t.AbsCumDelta <= sd;
            vars = {'DateTime', 'Price', 'VolBuy', 'VolSell'};
            tt = t(rows, vars);
            resample_volume();
            i = i + 1;
        end
        revert_for_table();
        
    case 'timeseconds'
        sw = 1;
        ttable = table2timetable(t);
        mysum = @(x) sum(x ~= 0);
%        DateTime = retime(ttable(:,{'DateTime'}), 'secondly');
        high = retime(ttable(:,{'Price'}), 'secondly', 'max');
        high.Properties.VariableNames{1} = 'high';
        low = retime(ttable(:,{'Price'}), 'secondly', 'min');
        low.Properties.VariableNames{1} = 'low';
        open = retime(ttable(:,{'Price'}), 'secondly', 'firstvalue');
        open.Properties.VariableNames{1} = 'open';
        close = retime(ttable(:,{'Price'}), 'secondly', 'lastvalue');
        close.Properties.VariableNames{1} = 'close';
        vB = retime(ttable(:,{'VolBuy'}), 'secondly', 'sum');
        vB.Properties.VariableNames{1} = 'vB';
        vS = retime(ttable(:,{'VolSell'}), 'secondly', 'sum');
        vS.Properties.VariableNames{1} = 'vS';
        nB = retime(ttable(:,{'VolBuy'}), 'secondly', mysum);
        nB.Properties.VariableNames{1} = 'nB';
        nS = retime(ttable(:,{'VolSell'}), 'secondly', mysum);
        nS.Properties.VariableNames{1} = 'nS';
end
   
    function resample_volume()
        
        da(i) = tt.DateTime(end);
        hi(i) = max(tt.Price);
        lo(i) = min(tt.Price);
        op(i) = tt.Price(1);
        cl(i) = tt.Price(end);
        vBuy(i) = sum(tt.VolBuy);
        vSell(i) = sum(tt.VolSell);
        nBuy(i) = sum(tt.VolBuy ~= 0);
        nSell(i) = sum(tt.VolSell ~= 0);
        dTime(i) = seconds(tt.DateTime(end) - tt.DateTime(1));
        if dTime(i) == 0
            dTime(i) = 1;
        end
        TspeedBuy(i) = nBuy(i) / dTime(i);
        TspeedSell(i) = nSell(i) / dTime(i);
        vto(i) = (nBuy(i)*vBuy(i) - nSell(i)*vSell(i)) / (nBuy(i)*vBuy(i) + nSell(i)*vSell(i));
        
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
        dTime(i) = seconds(t.DateTime(sd) - t.DateTime(ss));
        if dTime(i) == 0
            dTime(i) = 1;
        end
        TspeedBuy(i) = nBuy(i) / dTime(i);
        TspeedSell(i) = nSell(i) / dTime(i);
        vto(i) = (nBuy(i)*vBuy(i) - nSell(i)*vSell(i)) / (nBuy(i)*vBuy(i) + nSell(i)*vSell(i));
    end

    function revert_for_table()
        %    d = datenum(da');
        DateTime = da';
        high = hi';
        low = lo';
        open = op';
        close = cl';
        vB = vBuy';
        vS = vSell';
        nB = nBuy';
        nS = nSell';
        dT = dTime';
        TsBuy = TspeedBuy';
        TsSell = TspeedSell';
        VTO = vto';
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
        dTime = zeros(1, temp);
        da = repmat(datetime(0, 0, 0, 0, 0, 0), 1, temp);
        
    end
if sw == 1
    p  = [close vB vS nB nS];
    z= timetable2table(p);
    z.VTO = fillmissing((z.vB.*z.nB - z.vS.*z.nS)./(z.vB.*z.nB + z.vS.*z.nS), 'linear');
    y = table2timetable(z);
else
    y = table(DateTime, high, low, open, close, vB, vS, nB, nS, dT, TsBuy, TsSell, VTO);
end
end
