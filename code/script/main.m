initialize; config;

% simulate multipath flat channel based on tapped-delay line model
[channelAmplitude] = frequency_flat_channel(nSubbands, nTxs, centerFrequency);


% [current, rate] = wipt(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio, minCurrentGain);
[currentDecoupling, rateDecoupling] = wipt_decoupling(nSubbands, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio, minCurrentGain);
[currentLowerBound, rateLowerBound] = wipt_lower_bound(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio, minCurrentGain);
[currentNoPowerWaveform, rateNoPowerWaveform] = wipt_no_power_waveform(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio, minCurrentGain);

flag = 1;
