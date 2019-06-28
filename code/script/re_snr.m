initialize; config;
%% Channel
[channelAmplitude] = channel_amplitude(nSubbands, nTxs, centerFrequency, bandwidth, channelMode);
%% R-E region samples
currentDecoupling = zeros(nSnrCases, nRateSamples); rateDecoupling = zeros(nSnrCases, nRateSamples);
currentLowerBound = zeros(nSnrCases, nRateSamples); rateLowerBound = zeros(nSnrCases, nRateSamples);
currentNoPowerWaveform = zeros(nSnrCases, nRateSamples); rateNoPowerWaveform = zeros(nSnrCases, nRateSamples);
for iSnrCase = 1: nSnrCases
    for iRateSample = 1: nRateSamples
        [currentDecoupling(iSnrCase, iRateSample), rateDecoupling(iSnrCase, iRateSample)] = wipt_decoupling(nSubbandsRef, channelAmplitude{iSubbandCase}, k2, k4, txPower, noisePower(iSnrCase), resistance, maxIter, minSubbandRate(iRateSample), minCurrentGainRatio, minCurrentGain);
        [currentLowerBound(iSnrCase, iRateSample), rateLowerBound(iSnrCase, iRateSample)] = wipt_lower_bound(nSubbandsRef, nTxs, channelAmplitude{iSubbandCase}, k2, k4, txPower, noisePower(iSnrCase), resistance, maxIter, minSubbandRate(iRateSample), minCurrentGainRatio, minCurrentGain);
        [currentNoPowerWaveform(iSnrCase, iRateSample), rateNoPowerWaveform(iSnrCase, iRateSample)] = wipt_no_power_waveform(nSubbandsRef, channelAmplitude{iSubbandCase}, k2, k4, txPower, noisePower(iSnrCase), resistance, maxIter, minSubbandRate(iRateSample), minCurrentGainRatio, minCurrentGain);
    end
end
%% R-E region plots
figure("SNR = 10 dB");
plot(rateDecoupling(1, :), currentDecoupling(1, :));
hold on;
plot(rateLowerBound(1, :), currentLowerBound(1, :));
hold on;
plot(rateNoPowerWaveform(1, :), currentNoPowerWaveform(1, :));
hold on;
hold off;
grid on; grid minor;
legend("Superposed waveform", "No power waveform", "Lower bound");
xlabel("Rate [bps/Hz]");
ylabel("I_{DC} [\muA]")

figure("SNR = 20 dB");
plot(rateDecoupling(2, :), currentDecoupling(2, :));
hold on;
plot(rateLowerBound(2, :), currentLowerBound(2, :));
hold on;
plot(rateNoPowerWaveform(2, :), currentNoPowerWaveform(2, :));
hold on;
hold off;
grid on; grid minor;
legend("Superposed waveform", "No power waveform", "Lower bound");
xlabel("Rate [bps/Hz]");
ylabel("I_{DC} [\muA]")

figure("SNR = 30 dB");
plot(rateDecoupling(3, :), currentDecoupling(3, :));
hold on;
plot(rateLowerBound(3, :), currentLowerBound(3, :));
hold on;
plot(rateNoPowerWaveform(3, :), currentNoPowerWaveform(3, :));
hold on;
hold off;
grid on; grid minor;
legend("Superposed waveform", "No power waveform", "Lower bound");
xlabel("Rate [bps/Hz]");
ylabel("I_{DC} [\muA]")

figure("SNR = 40 dB");
plot(rateDecoupling(4, :), currentDecoupling(4, :));
hold on;
plot(rateLowerBound(4, :), currentLowerBound(4, :));
hold on;
plot(rateNoPowerWaveform(4, :), currentNoPowerWaveform(4, :));
hold on;
hold off;
grid on; grid minor;
legend("Superposed waveform", "No power waveform", "Lower bound");
xlabel("Rate [bps/Hz]");
ylabel("I_{DC} [\muA]")
