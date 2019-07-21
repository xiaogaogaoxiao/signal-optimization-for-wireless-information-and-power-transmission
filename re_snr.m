initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
% obtain the channel amplitude corresponding to the subband frequency
[Channel] = channel_amplitude(Transceiver, Channel);
% plot channel frequency response
plot_channel;
% save([pwd '/data/channel.mat'], 'Channel');
% load([pwd '/data/channel.mat']);
%% R-E region samples
currentDecoupling = zeros(nSnrCases, nRateSamples); rateDecoupling = zeros(nSnrCases, nRateSamples);
currentLowerBound = zeros(nSnrCases, nRateSamples); rateLowerBound = zeros(nSnrCases, nRateSamples);
currentNoPowerWaveform = zeros(nSnrCases, nRateSamples); rateNoPowerWaveform = zeros(nSnrCases, nRateSamples);

try
    gapFrequency = bandwidth / nSubbandsRef;
    sampleFrequency = centerFrequency - (nSubbandsRef - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbandsRef - 1) / 2 * gapFrequency;
    [channelAmplitude] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode);
    for iSnrCase = 1: nSnrCases
        for iRateSample = 1: nRateSamples
            [currentDecoupling(iSnrCase, iRateSample), rateDecoupling(iSnrCase, iRateSample)] = wipt_decoupling(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnrCase), resistance, minSubbandRate(iRateSample), minCurrentGain);
            [currentLowerBound(iSnrCase, iRateSample), rateLowerBound(iSnrCase, iRateSample)] = wipt_lower_bound(nSubbandsRef, tx, channelAmplitude, k2, k4, txPower, noisePower(iSnrCase), resistance, minSubbandRate(iRateSample), minCurrentGain);
            [currentNoPowerWaveform(iSnrCase, iRateSample), rateNoPowerWaveform(iSnrCase, iRateSample)] = wipt_no_power_waveform(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnrCase), resistance, minSubbandRate(iRateSample), minCurrentGain);
        end
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
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
legend('Superposed waveform', 'Lower bound', 'No power waveform');
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
legend('Superposed waveform', 'Lower bound', 'No power waveform');
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
legend('Superposed waveform', 'Lower bound', 'No power waveform');
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
legend('Superposed waveform', 'Lower bound', 'No power waveform');
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')

save('data_snr.mat');
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
