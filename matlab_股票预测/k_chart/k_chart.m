clc
clear
close all
data=xlsread('D:\desktop\matlab_股票预测_11月28日\data.xlsx');

%对于矩阵输入，Data 是由存储在相应列中的开盘价、最高价、最低价和收盘价组成的 M × 4 矩阵。
% 时间表和包含 M 行的表必须包含以下名称的变量：'Open'、'High'、'Low' 和 'Close'（不区分大小写）
data_open=data(:,1);
data_high=data(:,2);
data_low=data(:,3);
data_close=data(:,4);
data_k=[data_open,data_high,data_low,data_close];
% subplot(211)

candlell(data_k)
title('股市K线预测')
axis([0,200,3.7,5])
set(gca,'linewidth',2,'fontsize',24);
