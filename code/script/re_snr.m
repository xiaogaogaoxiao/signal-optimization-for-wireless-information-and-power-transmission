initialize; config;
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
        [currentLowerBound(iSnr, iSample), rateLowerBound(iSnr, iSample)] = wipt_lower_bound(nSubbandsRef, nTxs, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
        [currentNoPowerWaveform(iSnr, iSample), rateNoPowerWaveform(iSnr, iSample)] = wipt_no_power_waveform(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, maxIter, minRate(iSample), minCurrentGainRatio, minCurrentGain);
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
