initialize; config;
%% Channel
% tapped-delay line by HIPERLAN/2 model B
tapDelay = zeros(nTxs, 18);
tapGain = zeros(nTxs, 18);
for iTx = 1: nTxs
    [tapDelay(iTx, :), tapGain(iTx, :)] = hiperlan2_B();
end

[frequencyResponse, basebandFrequency] = frequency_response(tapDelay, tapGain, centerFrequency, bandwidth, channelMode);
index = find(basebandFrequency >= -bandwidth / 2 & basebandFrequency <= bandwidth / 2);

figure('Name', sprintf('Frequency response of the frequency-%s channel', channelMode));
plot(basebandFrequency / 1e6, frequencyResponse);
hold on;
plot(basebandFrequency(index) / 1e6, frequencyResponse(index));
grid on; grid minor;
legend([num2str(2.5 * bandwidth / 1e6) ' MHz'], [num2str(bandwidth / 1e6) ' MHz']);
xlabel('Frequency [MHz]');
ylabel('Frequency response');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);
yticks(0: 0.2: 10);

% save([pwd '/data/channel.mat'], 'tapDelay', 'tapGain');
% load([pwd '/data/channel.mat']);
%% R-E region samples
currentDecoupling = zeros(nSnrCases, nRateSamples); rateDecoupling = zeros(nSnrCases, nRateSamples);
currentLowerBound = zeros(nSnrCases, nRateSamples); rateLowerBound = zeros(nSnrCases, nRateSamples);
currentNoPowerWaveform = zeros(nSnrCases, nRateSamples); rateNoPowerWaveform = zeros(nSnrCases, nRateSamples);

gapFrequency = bandwidth / nSubbandsRef;
sampleFrequency = centerFrequency - (nSubbandsRef - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbandsRef - 1) / 2 * gapFrequency;
[channelAmplitude] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode);
for iSnrCase = 1: nSnrCases
    parfor iRateSample = 1: nRateSamples
        [currentDecoupling(iSnrCase, iRateSample), rateDecoupling(iSnrCase, iRateSample)] = wipt_decoupling(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnrCase), resistance, minSubbandRate(iRateSample), minCurrentGain);
        [currentLowerBound(iSnrCase, iRateSample), rateLowerBound(iSnrCase, iRateSample)] = wipt_lower_bound(nSubbandsRef, nTxs, channelAmplitude, k2, k4, txPower, noisePower(iSnrCase), resistance, minSubbandRate(iRateSample), minCurrentGain);
        [currentNoPowerWaveform(iSnrCase, iRateSample), rateNoPowerWaveform(iSnrCase, iRateSample)] = wipt_no_power_waveform(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnrCase), resistance, minSubbandRate(iRateSample), minCurrentGain);
    end
end
%% R-E region plots
figure('Name', 'SNR = 10 dB');
plot(rateDecoupling(1, :), currentDecoupling(1, :) * 1e6);
hold on;
plot(rateLowerBound(1, :), currentLowerBound(1, :) * 1e6);
hold on;
plot(rateNoPowerWaveform(1, :), currentNoPowerWaveform(1, :) * 1e6);
hold on;
hold off;
grid on; grid minor;
legend('Superposed waveform', 'No power waveform', 'Lower bound');
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')

figure('Name', 'SNR = 20 dB');
plot(rateDecoupling(2, :), currentDecoupling(2, :) * 1e6);
hold on;
plot(rateLowerBound(2, :), currentLowerBound(2, :) * 1e6);
hold on;
plot(rateNoPowerWaveform(2, :), currentNoPowerWaveform(2, :) * 1e6);
hold on;
hold off;
grid on; grid minor;
legend('Superposed waveform', 'No power waveform', 'Lower bound');
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')

figure('Name', 'SNR = 30 dB');
plot(rateDecoupling(3, :), currentDecoupling(3, :) * 1e6);
hold on;
plot(rateLowerBound(3, :), currentLowerBound(3, :) * 1e6);
hold on;
plot(rateNoPowerWaveform(3, :), currentNoPowerWaveform(3, :) * 1e6);
hold on;
hold off;
grid on; grid minor;
legend('Superposed waveform', 'No power waveform', 'Lower bound');
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')

figure('Name', 'SNR = 40 dB');
plot(rateDecoupling(4, :), currentDecoupling(4, :) * 1e6);
hold on;
plot(rateLowerBound(4, :), currentLowerBound(4, :) * 1e6);
hold on;
plot(rateNoPowerWaveform(4, :), currentNoPowerWaveform(4, :) * 1e6);
hold on;
hold off;
grid on; grid minor;
legend('Superposed waveform', 'No power waveform', 'Lower bound');
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')

save('data_snr.mat');
