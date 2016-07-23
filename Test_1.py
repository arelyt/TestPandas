#!/usr/bin/python
import numpy
import pandas as pd
from pylab import *

bhp = pd.read_csv('BHP.csv', delimiter=',', usecols=(6,), unpack=True)

bhp_returns = numpy.diff(bhp) / bhp[: -1]

vale = pd.read_csv('VALE.csv', delimiter=',', usecols=(6,), unpack=True)

vale_returns = numpy.diff(vale) / vale[: -1]
