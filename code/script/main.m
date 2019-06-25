initialize; config;
%% Rate-energy region as a function of subband count
currentDecoupling = zeros(nCases, nSamples); rateDecoupling = zeros(nCases, nSamples);
currentNoPowerWaveform = zeros(nCases, nSamples); rateNoPowerWaveform = zeros(nCases, nSamples);
for iCase = 1: nCases
    % simulate multipath flat channel based on tapped-delay line model
%     [channelAmplitude] = frequency_flat_channel(nSubbands(iCase), nTxs, centerFrequency);
    [channelAmplitude] = frequency_selective_channel(nSubbands(iCase), nTxs, centerFrequency, bandwidth);
    for iSample = 1: nSamples
        [currentDecoupling(iCase, iSample), rateDecoupling(iCase, iSample)] = wipt_decoupling(nSubbands(iCase), channelAmplitude, k2, k4, txPower, noisePowerRef, resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
        [currentNoPowerWaveform(iCase, iSample), rateNoPowerWaveform(iCase, iSample)] = wipt_no_power_waveform(nSubbands(iCase), nTxs, channelAmplitude, k2, k4, txPower, noisePowerRef, resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
    end
end
flag = 1;
%% Rate-energy region as a function of SNR
currentDecoupling = zeros(nSnrs, nSamples); rateDecoupling = zeros(nSnrs, nSamples);
currentLowerBound = zeros(nSnrs, nSamples); rateLowerBound = zeros(nSnrs, nSamples);
currentNoPowerWaveform = zeros(nSnrs, nSamples); rateNoPowerWaveform = zeros(nSnrs, nSamples);
% simulate multipath flat channel based on tapped-delay line model
% [channelAmplitude] = frequency_flat_channel(nSubbands(iCase), nTxs, centerFrequency);
[channelAmplitude] = frequency_selective_channel(nSubbandsRef, nTxs, centerFrequency, bandwidth);
for iSnr = 1: nSnrs
    for iSample = 1: nSamples
        [currentDecoupling(iSnr, iSample), rateDecoupling(iSnr, iSample)] = wipt_decoupling(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
        [currentLowerBound(iSnr, iSample), rateLowerBound(iSnr, iSample)] = wipt_lower_bound(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
        [currentNoPowerWaveform(iSnr, iSample), rateNoPowerWaveform(iSnr, iSample)] = wipt_no_power_waveform(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
    end
end
