#!/usr/bin/python
import datetime as dt
import numpy
import pandas as pd
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
#sec = bhp['<DATE>_<TIME>_<MSEC>'].to_datetime('<DATE>_<TIME>_<MSEC>')
#print sec
#bhp_returns = numpy.diff(bhp) / bhp[: -1]

# vale = pd.read_csv('VALE.csv', delimiter=',', usecols=(6,), unpack=True)

# vale_returns = numpy.diff(vale) / vale[: -1]
