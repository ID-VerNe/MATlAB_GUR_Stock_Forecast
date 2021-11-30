function layers=get_gru_net(wd)
%网络架构
numFeatures=wd;
numResponses=1;
numHiddenUnits=20;

layers=[sequenceInputLayer(numFeatures)
    gruLayer(numHiddenUnits)
    dropoutLayer(0.2)
    gruLayer(numHiddenUnits)
    dropoutLayer(0.2)
    fullyConnectedLayer(numResponses)
    regressionLayer];

end
