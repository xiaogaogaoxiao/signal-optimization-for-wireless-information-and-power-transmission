initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
plot_response;
% obtain the channel amplitude corresponding to the carrier frequency
[Channel] = channel_amplitude(Transceiver, Channel);
save([pwd '/data/channel.mat']);
% load([pwd '/data/channel.mat']);
%% R-E region samples
re_initialize;
rateDecoupling = zeros(Variable.nSubbandCases, Variable.nSamples); currentDecoupling = zeros(Variable.nSubbandCases, Variable.nSamples);
rateLowerBound = zeros(Variable.nSubbandCases, Variable.nSamples); currentLowerBound = zeros(Variable.nSubbandCases, Variable.nSamples);
rateNoPowerWaveform = zeros(Variable.nSubbandCases, Variable.nSamples); currentNoPowerWaveform = zeros(Variable.nSubbandCases, Variable.nSamples);
try
    for iCase = 1: Variable.nSubbandCases
        gapFrequency = bandwidth / nSubbands(iSubbandCase);
        sampleFrequency = centerFrequency - (nSubbands(iSubbandCase) - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbands(iSubbandCase) - 1) / 2 * gapFrequency;
        [channelAmplitude] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode);
        for iRateSample = 1: nRateSamples
            [currentDecoupling(iSubbandCase, iRateSample), rateDecoupling(iSubbandCase, iRateSample)] = wipt_decoupling(nSubbands(iSubbandCase), channelAmplitude, k2, k4, txPower, noisePowerRef, resistance, minSubbandRate(iRateSample), minCurrentGain);
            [currentNoPowerWaveform(iSubbandCase, iRateSample), rateNoPowerWaveform(iSubbandCase, iRateSample)] = wipt_no_power_waveform(nSubbands(iSubbandCase), channelAmplitude, k2, k4, txPower, noisePowerRef, resistance, minSubbandRate(iRateSample), minCurrentGain);
        end
    end
catch
    pushbullet.pushNote(deviceId, 'MATLAB Assist', 'Houston, we have a problem');
end

figure('Name', 'Superposed waveforms');
for iSubbandCase = 1: nSubbandCases
    plot(rateDecoupling(iSubbandCase, :), currentDecoupling(iSubbandCase, :) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(cellstr(num2str(nSubbands', 'N = %d')));
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');

figure('Name', 'No power waveform');
for iSubbandCase = 1: nSubbandCases
    plot(rateNoPowerWaveform(iSubbandCase, :), currentNoPowerWaveform(iSubbandCase, :) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(cellstr(num2str(nSubbands', 'N = %d')));
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');

save('data_subband.mat');
pushbullet.pushNote(deviceId, 'MATLAB Assist', 'Job''s done!');
