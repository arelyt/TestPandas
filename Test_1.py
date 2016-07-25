#!/usr/bin/python
import matplotlib.pyplot as plt
from matplotlib.finance import candlestick_ohlc, candlestick2_ohlc
import matplotlib.dates as mdates
import datetime as dt
import numpy
import pandas as pd
#matplotlib.style.use('ggplot')

from pylab import *

#dateparse = lambda dates: pd.datetime.strptime(dates, '%Y-%m-%d %H:%M:%S.%MS')

def parse(x):
    return dt.datetime.strptime(x, '%Y%m%d %H:%M:%S %f')

bhp = pd.read_csv('RIM6_4.trd', usecols=(0, 1, 2, 3, 4, 5, 6),
                  parse_dates={'DateTime': [0, 1]},
                  index_col=0)
print bhp
print type(bhp.index)
print bhp.index
print bhp.columns
bhp = bhp.rename(columns={'<LAST>': 'Price', '<VOL>': 'Volume'})
print bhp
res = bhp.Price.resample('1s').ohlc()
print res
res.reset_index(inplace=True)
#res.DateTime = mdates.date2num(res.DateTime)
dataAr = [tuple(x) for x in res[['DateTime', 'open', 'high', 'low', 'close']].to_records(index=False)]
plt.ion()
#res = res.cumsum()
#plt.figure()
#res.plot()
fig = plt.figure()
ax1 = plt.subplot(1, 1, 1)
candlestick_ohlc(ax1, dataAr)
plt.show()
print 1
#print type(res.index)
#print res.index
#print res.columns
#fig, ax = plt.subplots()
#csticks = candlestick_ohlc(ax, res[['<LAST>'][0, 1, 2, 3]].values)
#plt.show()
#sec = bhp['<DATE>_<TIME>_<MSEC>'].to_datetime('<DATE>_<TIME>_<MSEC>')
#print sec
#bhp_returns = numpy.diff(bhp) / bhp[: -1]

# vale = pd.read_csv('VALE.csv', delimiter=',', usecols=(6,), unpack=True)

# vale_returns = numpy.diff(vale) / vale[: -1]
