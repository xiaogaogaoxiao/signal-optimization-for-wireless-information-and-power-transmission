initialize; config;

% simulate multipath channel based on tapped-delay line model
[impulseResponse] = impulse_response(nSubbands, nTxs, carrierFreq);
% obtain the absolute value of channel impulse response
channelAmplitude = abs(impulseResponse);


% [dcCurrentGeneral, rateGeneral] = wipt_general(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, iterMax, rateMin);
% [dcCurrentDecoupling, rateDecoupling] = wipt_decoupling(nSubbands, channelAmplitude, k2, k4, txPower, noisePower, resistance, iterMax, rateMin);
[dcCurrentDecoupling, rateDecoupling] = wipt_lower_bound(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, iterMax, rateMin);
flag = 1;
