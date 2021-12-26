function kline(line,xlRange,MaxEpochs)
close all;clc;
rand('seed',10);  %设置随机数种子
%% I.加载数据
month=xlsread('input.xlsx');
% pressure=xlsread('output.xlsx');
pressure=xlsread('SH600028.csv');
pressure=pressure(:,line);
data_x=month';data_y=pressure';
%% II.数据预处理
mu=mean(data_y);%计算均值
sig=std(data_y);%计算标准差
data_y=(data_y-mu)/sig;%数据归一化
%% III.数据准备
wd=6;
len=numel(data_y);%计算data_y中元素数目
wdata=[];
for i=1:1:len-wd
    di=data_y(i:i+wd);
    wdata=[wdata;di];
end
wdata_origin=wdata;
index_list=randperm(size(wdata,1));%整数随机排序
ind=round(0.95*length(index_list));%四舍五入
train_index=index_list(1:ind);
test_index=index_list(ind+1:end);
train_index=sort(train_index);
test_index=sort(test_index);

%% IV.划分训练集、测试集的数据和标签
dataTrain=wdata(train_index,:);
dataTest=wdata(test_index,:);
XTrain=dataTrain(:,1:end-1)';
YTrain=dataTrain(:,end)';
XTest=dataTest(:,1:end-1)';
YTest=dataTest(:,end)';

%% V.网络构建
layers=get_gru_net(wd);
options=trainingOptions('adam',...
    'MaxEpochs',MaxEpochs,...
    'GradientThreshold',1,...
    'InitialLearnRate',0.001, ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',125,...
    'LearnRateDropFactor',0.2,...
    'Verbose',0,...
    'Plots','training-progress');

%% VI.训练
net=trainNetwork(XTrain,YTrain,layers,options);
%% VII.测试
Xall=wdata_origin(:,1:end-1)';
Yall=wdata_origin(:,end)';
YPred=predict(net,Xall,'MiniBatchSize',1);
rmse=mean((YPred(:)-Yall(:)).^2);

YPred=YPred*sig+mu;
YPred=YPred(1,end-199:end);
YPred=YPred';
xlswrite('data.xlsx',YPred,'Sheet1',xlRange);
end



