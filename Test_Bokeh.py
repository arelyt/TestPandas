from math import pi
import datetime as dt
import pandas as pd
from bokeh.plotting import figure, output_notebook, show
import numpy as np
output_notebook()


def parse(x):
    return dt.datetime.strptime(x, '%Y%m%d %H:%M:%S')


bhp = pd.read_csv('RIM6_4.trd', usecols=(0, 1, 4, 5, 6), header=0, parse_dates={'DateTime': [0, 1]}, index_col=[0])

bhp = bhp.rename(columns={'<LAST>': 'Price', '<VOL>': 'Vol', '<DIRECTION>': 'Dir'})

bhp['VolSell'] = bhp.apply(lambda row: (row['Vol'] if row['Dir'] == 'Sell' else 0), axis=1)
bhp['VolBuy'] = bhp.apply(lambda row: (row['Vol'] if row['Dir'] == 'Buy' else 0), axis=1)

res = bhp.Price.resample('60s').ohlc()
resSell = bhp.VolSell.resample('60s').sum()
resBuy = bhp.VolBuy.resample('60s').sum()

res_new = res.join(pd.DataFrame(resSell))
res_new1 = res_new.join(pd.DataFrame(resBuy))

print res_new1

mids = (res.open + res.close)/2
spans = abs(res.close - res.open)
print res, mids, spans
inc = res.close > res.open
dec = res.open > res.close

w = 12*60*60

p = figure(x_axis_type='datetime', plot_width=800, plot_height=500, title='RIM6 CandleStick')
p.xaxis.major_label_orientation = pi/4
p.grid.grid_line_alpha = 0.3
p.segment(res.DateTime, res.high, res.DateTime, res.low, color='black')
p.rect(res.DateTime[inc], mids[inc], w, spans[inc], fill_color='#6CF350', line_color='green')
p.rect(res.DateTime[dec], mids[dec], w, spans[dec], fill_color='#FF0000', line_color='red')
show(p)
