#!/usr/bin/env python
# -*- coding: utf-8; py-indent-offset:4 -*-
###############################################################################
#
# Copyright (C) 2015-2023 Daniel Rodriguez
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################
import yfinance as yf
from datetime import datetime
import backtrader as bt
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


class SmaCross(bt.SignalStrategy):
    def __init__(self):
        sma1 = bt.ind.SMA(period=10)
        sma2 = bt.ind.SMA(period=30)
        crossover = bt.ind.CrossOver(sma1, sma2)
        self.signal_add(bt.SIGNAL_LONG, crossover)


# Create a cerebro instance
cerebro = bt.Cerebro()
cerebro.addstrategy(SmaCross)

# Download hourly data from Yahoo Finance using yfinance
data = yf.download('IBM', start='2024-07-01', end='2024-09-13', interval='1h', auto_adjust=True)

# Convert the downloaded data to a PandasData feed for Backtrader
data_bt = bt.feeds.PandasData(dataname=data)

# Add the data to the cerebro instance
cerebro.adddata(data_bt)

# Run the backtest
cerebro.run()

# Plot the results and retrieve the figure and axes
fig, ax_list = cerebro.plot(iplot=False)[0]  # `iplot=False` to prevent immediate display

# Customize the x-axis to show date increments
ax = ax_list[0]  # Get the first axis (main plot)
ax.xaxis.set_major_locator(mdates.HourLocator(interval=24))  # Set major ticks every 24 hours
ax.xaxis.set_minor_locator(mdates.HourLocator(interval=6))  # Set minor ticks every 6 hours

# Format the date labels on the x-axis
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))

# Rotate the x-axis labels for better readability
plt.setp(ax.get_xticklabels(), rotation=45, ha="right")

# Show the plot
plt.show()
