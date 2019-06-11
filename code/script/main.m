initialize; config;

% simulate multipath channel based on tapped-delay line model
[impulseResponse] = impulse_response(nSubbands, nTxs, carrierFreq);
% obtain the absolute value of channel impulse response
channelAmplitude = abs(impulseResponse);

[mutualInfo] = wipt_siso(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, iterMax, rateMin);
