from math import pi
import datetime as dt
import pandas as pd
from bokeh.plotting import figure, output_notebook, show

output_notebook()
def parse(x):
    return dt.datetime.strptime(x, '%Y%m%d %H:%M:%S')

#bhp = pd.read_csv('RIM6_4.trd', usecols=(0, 1, 2, 3, 4, 5, 6),
#                  parse_dates={'Date': [0, 1, 2]},
#                  index_col=0)
bhp = pd.read_csv('RIM6_4.trd', usecols=(0, 1, 4, 5, 6), parse_dates={'Date': [0, 1]}, index_col=[0, 1],
                  date_parser=parse)


print bhp
print type(bhp.index)
#print bhp.index
print bhp.columns

bhp = bhp.rename(columns={'<LAST>': 'Price', '<VOL>': 'Volume'})
bhp['Date'] = pd.to_datetime(bhp['Date'])
#bhp.index = pd.to_datetime(bhp.index)
res = bhp.Price.resample('60s').ohlc()
#res = bhp.resample('60s', how={'Price': 'ohlc'})
mids = (res.open + res.close)/2
spans = abs(res.close - res.open)
print res, mids, spans
inc = res.close > res.open
dec = res.open > res.close
w = 12*60*60*1000
print inc, dec
print res.DateTime[5]

p = figure(x_axis_type='datetime', plot_width=800, plot_height=500, title='RIM6 CandleStick')
p.xaxis.major_label_orientation = pi/4
p.grid.grid_line_alpha = 0.3
p.segment(res.DateTime, res.high, res.DateTime, res.low, color='black')
p.rect(res.DateTime[inc], mids[inc], w, spans[inc], fill_color='#D5E1DD', line_color='black')
p.rect(res.DateTime[dec], mids[dec], w, spans[dec], fill_color='#F2583E', line_color='black')
show(p)
