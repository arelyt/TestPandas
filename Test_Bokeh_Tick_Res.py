# coding=utf-8
import numpy as np
from math import pi
import datetime as dt
import pandas as pd
from bokeh.plotting import figure, output_file, show
from bokeh.models import LogAxis, LinearAxis, Range1d
# output_notebook()


tick = pd.read_csv('RIM6_4.trd', usecols=(0, 1, 2, 3, 4, 5, 6),
                   parse_dates={'DateTime': [0,1]}, index_col=False)
tick = tick.rename(columns={'<LAST>': 'Price', '<VOL>': 'Vol', '<DIRECTION>': 'Dir'})
tick.ix[tick.Dir == 'Sell', 'VolSell'] = tick.Vol
tick.ix[tick.Dir == 'Buy', 'VolBuy'] = tick.Vol
Nticks = 300  # Количество тиков для бара и ресэмплинг

rows_list = []
for i in range(0, len(tick.index), Nticks):
    dict1 = {}

    op = tick.Price.iloc[i]
    hi = tick.Price.iloc[i:i + Nticks].max()
    lo = tick.Price.iloc[i:i + Nticks].min()

    if i + Nticks < len(tick.index):
        cl = tick.loc[i + Nticks - 1].Price
    else:
        cl = tick.loc[len(tick.index) - 1].Price

    vBuy = tick.VolBuy.iloc[i:i + Nticks].sum()
    vSell = tick.VolSell.iloc[i:i + Nticks].sum()
    nBuy = tick.VolBuy.iloc[i:i + Nticks].count()
    nSell = tick.VolSell.iloc[i:i + Nticks].count()
    tClose = tick.DateTime.iloc[i:i + Nticks].max()
    dtime = tick.DateTime.iloc[i:i + Nticks].max() - tick.DateTime.iloc[i:i + Nticks].min()
    dict1.update({'DateTime': tClose, 'open': op, 'high': hi,
                  'low': lo, 'close': cl, 'TickBuy': nBuy,
                  'VolBuy': vBuy, 'TickSell': nSell, 'VolSell': vSell, 'DeltaTime': dtime})
    rows_list.append(dict1)

res = pd.DataFrame(rows_list)
res['Dsec'] = res['DeltaTime'].dt.total_seconds()
res['TSpeedBuy'] = res['TickBuy']/res['Dsec']
res['TSpeedSell'] = res['TickSell']/res['Dsec']
res['VSpeedBuy'] = res['VolBuy']/res['Dsec']
res['VSpeedSell'] = res['VolSell']/res['Dsec']
res['OTO'] = ((res['TickBuy']-res['TickSell'])/(res['TickBuy']+res['TickSell'])*0.65
            + (res['VolBuy']-res['VolSell'])/(res['VolBuy']+res['VolSell'])*0.35)*100.0
mids = (res.open + res.close)/2
spans = abs(res.close - res.open)
# print res, mids, spans
inc = res.close > res.open
dec = res.open > res.close

w = 0.8
# print res.index[inc], mids, spans, inc, dec
p = figure(x_range=(0, len(res.index)), plot_width=1400, plot_height=1024, title='RIM6 CandleStick')
p.y_range = Range1d(start=90500, end=95000)
p.xaxis.major_label_orientation = pi/4
p.grid.grid_line_alpha = 0.3
p.segment(res.index.values, res.high, res.index.values, res.low, color='black')
p.rect(res.index[inc], mids[inc], w, spans[inc], fill_color='#6CF350', line_color='green')
p.rect(res.index[dec], mids[dec], w, spans[dec], fill_color='#FF0000', line_color='red')
# p.extra_y_ranges = {}
p.extra_y_ranges['TickSpeed'] = Range1d(start=0, end=100)
p.extra_y_ranges['OTO'] = Range1d(start=-60, end=60)
#p.line(res.index, res.TSpeedBuy, color='blue', y_range_name='TickSpeed', alpha=0.5)
p.line(res.index, res.TSpeedBuy.rolling(window=4).median(), color='green', y_range_name='TickSpeed', alpha=0.8)
#p.line(res.index, res.TSpeedSell, color='red', y_range_name='TickSpeed', alpha=0.5)
p.line(res.index, res.TSpeedSell.rolling(window=9).median(), color='red', y_range_name='TickSpeed', alpha=0.8)
p.line(res.index, res.OTO.rolling(window=15).mean(), color='brown', y_range_name='OTO', alpha=0.9)
p.add_layout(LogAxis(y_range_name='TickSpeed'), 'left')
p.add_layout(LinearAxis(y_range_name='OTO'), 'left')

output_file('Tick_resample_candlestick.html', title='RIM_4')
show(p)
