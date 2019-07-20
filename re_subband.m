initialize; config;
pushbullet.pushNote(deviceId, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% tapped-delay line by HIPERLAN/2 model B
tapDelay = zeros(tx, 18);
tapGain = zeros(tx, 18);
for iTx = 1: tx
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
%% R-E region
currentDecoupling = zeros(nSubbandCases, nRateSamples); rateDecoupling = zeros(nSubbandCases, nRateSamples);
currentNoPowerWaveform = zeros(nSubbandCases, nRateSamples); rateNoPowerWaveform = zeros(nSubbandCases, nRateSamples);

try
    for iSubbandCase = 1: nSubbandCases
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
