initialize; config;
% Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
% obtain the channel amplitude corresponding to the subband frequency
[Channel] = channel_amplitude(Transceiver, Channel);
% plot channel frequency response
plot_response;
% save([pwd '/data/channel.mat'], 'Channel');
% load([pwd '/data/channel.mat']);
%% R-E region samples
currentDecoupling = zeros(nSnrs, nSamples); rateDecoupling = zeros(nSnrs, nSamples);
currentLowerBound = zeros(nSnrs, nSamples); rateLowerBound = zeros(nSnrs, nSamples);
currentNoPowerWaveform = zeros(nSnrs, nSamples); rateNoPowerWaveform = zeros(nSnrs, nSamples);

try
    gapFrequency = bandwidth / nSubbandsRef;
    sampleFrequency = centerFrequency - (nSubbandsRef - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbandsRef - 1) / 2 * gapFrequency;
    [channelAmplitude] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode);
    for iSnr = 1: nSnrs
        for iSample = 1: nSamples
            [currentDecoupling(iSnr, iSample), rateDecoupling(iSnr, iSample)] = wipt_decoupling(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, minSubbandRate(iSample), minCurrentGain);
            [currentLowerBound(iSnr, iSample), rateLowerBound(iSnr, iSample)] = wipt_lower_bound(nSubbandsRef, tx, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, minSubbandRate(iSample), minCurrentGain);
            [currentNoPowerWaveform(iSnr, iSample), rateNoPowerWaveform(iSnr, iSample)] = wipt_no_power_waveform(nSubbandsRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, minSubbandRate(iSample), minCurrentGain);
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
