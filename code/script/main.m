initialize; config;

% simulate multipath channel based on tapped-delay line model
[channelAmplitude] = multipath_channel(nSubbands, nTxs, carrierFrequency);


[current, rate] = wipt(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio);
[currentDecoupling, rateDecoupling] = wipt_decoupling(nSubbands, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio);
[currentLowerBound, rateLowerBound] = wipt_lower_bound(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio);
[currentNoPowerWaveform, rateNoPowerWaveform] = wipt_no_power_waveform(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio);

flag = 1;
