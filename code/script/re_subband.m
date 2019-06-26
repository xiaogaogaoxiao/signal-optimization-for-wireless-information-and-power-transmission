initialize; config;
%% Rate-energy region as a function of subband count
currentDecoupling = zeros(nCases, nSamples); rateDecoupling = zeros(nCases, nSamples);
currentNoPowerWaveform = zeros(nCases, nSamples); rateNoPowerWaveform = zeros(nCases, nSamples);
for iCase = 1: nCases
    [channelAmplitude] = channel_realization(nSubbands(iCase), nTxs, centerFrequency, bandwidth, nRealizations, channelMode);
    for iSample = 1: nSamples
        [currentDecoupling(iCase, iSample), rateDecoupling(iCase, iSample)] = wipt_decoupling(nSubbands(iCase), channelAmplitude, k2, k4, txPower, noisePowerRef, resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
        [currentNoPowerWaveform(iCase, iSample), rateNoPowerWaveform(iCase, iSample)] = wipt_no_power_waveform(nSubbands(iCase), channelAmplitude, k2, k4, txPower, noisePowerRef, resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
    end
end
%% R-E region plots
figure('Name', 'Superposed waveforms');
for iCase = 1: nCases
    plot(rateDecoupling(iCase, :), currentDecoupling(iCase, :) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(cellstr(num2str(nSubbands', 'N = %d')));
xlabel("Rate [bps/Hz]");
ylabel("I_{DC} [\muA]")

figure('Name', 'No power waveform');
for iCase = 1: nCases
    plot(rateNoPowerWaveform(iCase, :), currentNoPowerWaveform(iCase, :) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(cellstr(num2str(nSubbands', 'N = %d')));
xlabel("Rate [bps/Hz]");
ylabel("I_{DC} [\muA]")
