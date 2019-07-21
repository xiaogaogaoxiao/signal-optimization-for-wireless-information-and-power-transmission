initialize; config;
% Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
% plot channel frequency response
plot_response;
% save([pwd '/data/channel.mat'], 'Channel');
% load([pwd '/data/channel.mat']);
%% R-E region samples
% calculate carrier frequency
Channel.gapFrequency = Channel.bandwidth / Channel.subbandRef;
Channel.sampleFrequency = Channel.centerFrequency - 0.5 * (Channel.bandwidth - Channel.gapFrequency): Channel.gapFrequency: Channel.centerFrequency + 0.5 * (Channel.bandwidth - Channel.gapFrequency);
% obtain the channel amplitude corresponding to the carrier frequency
[Channel] = channel_amplitude(Transceiver, Channel);
% initialize
Solution.currentDecoupling = zeros(Transceiver.nSnrs, Transceiver.nSamples);
Solution.currentLowerBound = zeros(Transceiver.nSnrs, Transceiver.nSamples);
Solution.currentNoPowerWaveform = zeros(Transceiver.nSnrs, Transceiver.nSamples);
Solution.rateDecoupling = zeros(Transceiver.nSnrs, Transceiver.nSamples);
Solution.rateLowerBound = zeros(Transceiver.nSnrs, Transceiver.nSamples);
Solution.rateNoPowerWaveform = zeros(Transceiver.nSnrs, Transceiver.nSamples);
% try
    for iSnr = 1: Transceiver.nSnrs
        % initialize with matched filers
        Solution.powerAmplitude = Channel.subbandAmplitude / norm(Channel.subbandAmplitude, 'fro') * sqrt(Transceiver.txPower);
        Solution.infoAmplitude = Channel.subbandAmplitude / norm(Channel.subbandAmplitude, 'fro') * sqrt(Transceiver.txPower);
        for iSample = 1: Transceiver.nSamples
            [Solution] = wipt_decoupling(Transceiver, Channel, Solution);
            [currentLowerBound(iSnr, iSample), rateLowerBound(iSnr, iSample)] = wipt_lower_bound(subbandRef, tx, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, minSubbandRate(iSample), minCurrentGain);
            [currentNoPowerWaveform(iSnr, iSample), rateNoPowerWaveform(iSnr, iSample)] = wipt_no_power_waveform(subbandRef, channelAmplitude, k2, k4, txPower, noisePower(iSnr), resistance, minSubbandRate(iSample), minCurrentGain);
        end
    end
% catch
%     Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
% end
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
