# coding:utf8

import math
from math import pi
import pandas as pd
from bokeh.plotting import figure, output_file, show
# from bokeh.layouts import gridplot
from bokeh.models import LinearAxis, LogAxis, Range1d
# from scipy.fftpack import fft, fftfreq, fftshift, rfft
output_file('Fourier.html')


tick = pd.read_csv('RIM6_4.trd', usecols=(0, 1, 2, 3, 4, 5, 6),
                   parse_dates={'DateTime': [0, 1]}, index_col=False)
tick = tick.rename(columns={'<LAST>': 'Price', '<VOL>': 'Vol', '<DIRECTION>': 'Dir'})
tick.ix[tick.Dir == 'Sell', 'VolSell'] = tick.Vol
tick.ix[tick.Dir == 'Buy', 'VolBuy'] = tick.Vol

Nticks = 500     # Количество тиков для бара и ресэмплинг по тикам
Nback = 64
Ndeltas = 500
TimeRes = '1s'  # Интервал ресэмплинга в секундах
delt = 1.0        # Interval FFT
fs = 1.0/delt      # Sampling frequency
dl = tick.fillna(0)
dl['CumVolBuy'] = dl['VolBuy'].cumsum()
dl['CumVolSell'] = dl['VolSell'].cumsum()
dl['Delta'] = dl['CumVolBuy'] - dl['CumVolSell']
dl['CumDelta'] = (dl['VolBuy'] - dl['VolSell']).cumsum()
dl['AbsCumDelta'] = (abs(dl['CumDelta']))
dl['New'] = abs(dl['AbsCumDelta']).diff()
dl['New1'] = abs(dl['New']).cumsum()
dl.iloc[:10000].to_csv('Deltas1.csv')

rows_list = []
mx = int(math.ceil(dl['AbsCumDelta'].max()))
dl.set_index('AbsCumDelta')
for i in range(0, mx):
    tmp = dl.loc[(dl['AbsCumDelta'] > float(i)) & (dl['AbsCumDelta'] <= float(i + 1))]
    tmp.set_index('Price')
    dict1 = {}

    op = tmp.Price.iloc[0]
    hi = tmp.Price.max()
    lo = tmp.Price.min()
    cl = tmp.Price.iloc[(len(tmp.index) - 1)]
    cumdelta = tmp.CumDelta.iloc[(len(tmp.index) - 1)]
    vBuy = tmp.VolBuy.sum()
    vSell = tmp.VolSell.sum()
    nBuy = tmp.VolBuy.count()
    nSell = tmp.VolSell.count()
    tClose = tmp.DateTime.max()
    dtime = (tmp.DateTime.max() - tmp.DateTime.min())
    dict1.update({'DateTime': tClose, 'open': op, 'high': hi,
                  'low': lo, 'close': cl, 'TickBuy': nBuy,
                  'VolBuy': vBuy, 'TickSell': nSell, 'VolSell': vSell, 'DeltaTime': dtime, 'CumDelta': cumdelta})
    rows_list.append(dict1)

res = pd.DataFrame(rows_list)

res['Dsec'] = res['DeltaTime'].dt.total_seconds()
res['TSpeedBuy'] = res['TickBuy'] / res['Dsec']
res['TSpeedSell'] = res['TickSell'] / res['Dsec']
res['VSpeedBuy'] = res['VolBuy'] / res['Dsec']
res['VSpeedSell'] = res['VolSell'] / res['Dsec']
res['OTO'] = ((res['TickBuy'] - res['TickSell']) / (res['TickBuy'] + res['TickSell']) * 0.65
              + (res['VolBuy'] - res['VolSell']) / (res['VolBuy'] + res['VolSell']) * 0.35) * 100.0
res['OTON'] = ((res['TickBuy'] * res['VolBuy'] - res['TickSell'] * res['VolSell']) /
               (res['TickBuy'] * res['VolBuy'] + res['TickSell'] * res['VolSell'])) * 100.0


# res = res.set_index('DateTime')
mids = (res.open + res.close)/2
spans = abs(res.close - res.open)
inc = res.close > res.open
dec = res.open > res.close
# w = 12*60*60
w = 0.5

p = figure(x_range=(0, len(res.index)), plot_width=800, plot_height=600, title='RIM6 CandleStick')
p.y_range = Range1d(start=90500, end=95000)
p.xaxis.major_label_orientation = pi/4
p.grid.grid_line_alpha = 0.3
p.segment(res.index.values, res.high, res.index.values, res.low, color='black')
p.rect(res.index[inc], mids[inc], w, spans[inc], fill_color='#6CF350', line_color='green')
p.rect(res.index[dec], mids[dec], w, spans[dec], fill_color='#FF0000', line_color='red')
p.extra_y_ranges = {'TickSpeed': Range1d(start=0, end=100), 'OTO': Range1d(start=-60, end=60),
                    'OTON': Range1d(start=-60, end=60), 'CumDelta': Range1d(start=-3000, end=52000)}
# p.line(res.index, res.TSpeedBuy, color='blue', y_range_name='TickSpeed', alpha=0.5)
p.line(res.index, res.TSpeedBuy.rolling(window=4).median(), color='green', y_range_name='TickSpeed', alpha=0.8)
# p.line(res.index, res.TSpeedSell, color='red', y_range_name='TickSpeed', alpha=0.5)
p.line(res.index, res.TSpeedSell.rolling(window=9).median(), color='red', y_range_name='TickSpeed', alpha=0.8)
p.line(res.index, res.OTO.rolling(window=15).mean(), color='brown', y_range_name='OTO', alpha=0.9)
p.line(res.index, res.OTON.rolling(window=15).mean(), color='blue', y_range_name='OTON', alpha=0.9)
p.line(res.index, res.CumDelta, color='black', y_range_name='CumDelta', alpha=0.9)
p.add_layout(LogAxis(y_range_name='TickSpeed'), 'left')
p.add_layout(LinearAxis(y_range_name='OTO'), 'left')
p.add_layout(LinearAxis(y_range_name='OTON'), 'left')
p.add_layout(LinearAxis(y_range_name='CumDelta'), 'left')
# show(p)
# l = figure(plot_width=800, plot_height=600, title='FFT')
# l.line(resfftfreq, resfft)
# m = gridplot([[p, l]])

show(p)
