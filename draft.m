%% Subband
a = channelAmplitude(1);
clearvars channelAmplitude;
channelAmplitude{1} = a;
channelAmplitude{2} = repmat(a,[2,1]);
channelAmplitude{3} = repmat(a,[4,1]);
channelAmplitude{4} = repmat(a,[8,1]);
channelAmplitude{5} = repmat(a,[16,1]);

for iCase = 1: Variable.nSubbandCases
    Channel.subband = Variable.subband(iCase);
    Channel.sampleFrequency = Variable.sampleFrequency{iCase};
    Channel.gapFrequency = Variable.gapFrequency(iCase);
    % obtain the channel amplitude corresponding to the carrier frequency
    [Channel] = channel_response(Transceiver, Channel);
    channelAmplitude{iCase} = Channel.subbandAmplitude;
end

Variable.nSubbandCases = 5;
Variable.nSamples = 41;
Variable.subband = [1 2 4 8 16];

for iCase = 1: Variable.nSubbandCases
    lambda = channelAmplitude{iCase}(:) .^ 2;
    subbandPower = water_filling(lambda, 2 * txPower, noisePowerRef);
    % average rate per subband
    maxRate(iCase) = sum(log2(1 + subbandPower / noisePowerRef.* lambda)) / nSubbands(iCase);
end

for iCase = 1: Variable.nSubbandCases
    rateDecoupling(iCase, Variable.nSamples + 1) = maxRate(iCase); currentDecoupling(iCase, Variable.nSamples + 1) = 0;
    rateNoPowerWaveform(iCase, Variable.nSamples + 1) = maxRate(iCase); currentNoPowerWaveform(iCase, Variable.nSamples + 1) = 0;
    [rateDecoupling(iCase, :), indexDecoupling] = sort(rateDecoupling(iCase, :)); currentDecoupling(iCase, :) = currentDecoupling(iCase, indexDecoupling);
    [rateNoPowerWaveform(iCase, :), indexNoPowerWaveform] = sort(rateNoPowerWaveform(iCase, :)); currentNoPowerWaveform(iCase, :) = currentNoPowerWaveform(iCase, indexNoPowerWaveform);
end
%% SNR
for iCase = 1: length(noisePower)
    lambda = channelAmplitude(:) .^ 2;
    subbandPower = water_filling(lambda, 2 * txPower, noisePower(iCase));
    % average rate per subband
    maxRate(iCase) = sum(log2(1 + subbandPower / noisePower(iCase).* lambda)) / nSubbandsRef;
end

for iCase = 1: Variable.nSnrCases
    rateDecoupling(iCase, nRateSamples + 1) = maxRate(iCase); currentDecoupling(iCase, nRateSamples + 1) = 0;
    rateLowerBound(iCase, nRateSamples + 1) = maxRate(iCase); currentLowerBound(iCase, nRateSamples + 1) = 0;
    rateNoPowerWaveform(iCase, nRateSamples + 1) = maxRate(iCase); currentNoPowerWaveform(iCase, nRateSamples + 1) = 0;
    [rateDecoupling(iCase, :), indexDecoupling] = sort(rateDecoupling(iCase, :)); currentDecoupling(iCase, :) = currentDecoupling(iCase, indexDecoupling);
    [rateLowerBound(iCase, :), indexLowerBound] = sort(rateLowerBound(iCase, :)); currentLowerBound(iCase, :) = currentLowerBound(iCase, indexLowerBound);
    [rateNoPowerWaveform(iCase, :), indexNoPowerWaveform] = sort(rateNoPowerWaveform(iCase, :)); currentNoPowerWaveform(iCase, :) = currentNoPowerWaveform(iCase, indexNoPowerWaveform);
end

rateLowerBound(:, 3:end) = rateNoPowerWaveform(:, 3:end);
for iCase = 1: Variable.nSnrCases
    currentLowerBound_ = currentLowerBound(iCase, :); currentNoPowerWaveform_ = currentNoPowerWaveform(iCase, :);
    currentLowerBound_(currentLowerBound_<currentNoPowerWaveform_) = currentNoPowerWaveform_(currentLowerBound_<currentNoPowerWaveform_);
    currentLowerBound(iCase, :) = currentLowerBound_;
end

clearvars currentLowerBound_ currentNoPowerWaveform_
%% MIMO
for iCase = 1: Variable.nRxCases
    [maxRate(iCase)] = wit(Transceiver{iCase}, Channel{iCase});
    rateMimo(iCase, Variable.nSamples + 1) = maxRate(iCase); currentMimo(iCase, Variable.nSamples + 1) = 0;
    [rateMimo(iCase, :), indexDecoupling] = sort(rateMimo(iCase, :)); currentMimo(iCase, :) = currentMimo(iCase, indexDecoupling);
end
%% PAPR
currentPapr(3, :) = max(currentPapr);
currentPapr(2, :) = max(currentPapr(1:2, :));
%% Optimal stragegy for medium N
legendStr = cell(3, 1);
figure('Name', 'Superposed waveform');
% WIPT
for iCase = 4
    plot(rateDecoupling(iCase, :), currentDecoupling(iCase, :) * 1e6, 'r');
    legendStr{1} = sprintf('WIPT (PS + TS): N = %d', Variable.subband(iCase));
    hold on;
end
% WIPT
for iCase = 4
    plot(rateDecoupling(iCase, 1:14), currentDecoupling(iCase, 1:14) * 1e6, 'k');
    legendStr{2} = sprintf('WIPT (PS): N = %d', Variable.subband(iCase));
    hold on;
end
% WIT
for iCase = 4
    scatter(maxRate(iCase), 0, 'k');
    legendStr{3} = sprintf('WIT: N = %d', Variable.subband(iCase));
    hold on;
end
% time-sharing
for iCase = 4
    plot([rateDecoupling(iCase, 1), maxRate(iCase)], [currentDecoupling(iCase, 1) * 1e6, 0], 'k--');
    legendStr{4} = sprintf('WIPT (TS): N = %d', Variable.subband(iCase));
    hold on;
end
% plot([rateDecoupling(iCase, 1), maxRate(iCase)], [currentDecoupling(iCase, 1) * 1e6, 0], 'r')
plot([rateDecoupling(iCase, 1), rateDecoupling(iCase, 14)], [currentDecoupling(iCase, 1), currentDecoupling(iCase, 14)] * 1e6, 'r');
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
ylim([0, 6]);
%% Optimum strategy for MIMO (N = 2)
legendStr = cell(4 * Variable.nRxCases, 1);
figure('Name', sprintf('MIMO: subband = %d', Channel{iCase}.subband));
% WIPT
for iCase = 1: Variable.nRxCases
    plot(rateMimo(iCase, :), currentMimo(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): Rx = %d', Variable.rx(iCase));
    hold on;
end
% WIT
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    scatter(maxRate(iCase), 0);
    legendStr{iCase + Variable.nRxCases} = sprintf('WIT: Rx = %d', Variable.rx(iCase));
    hold on;
end
% time-sharing
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    plot([rateMimo(iCase, 1), maxRate(iCase)], [currentMimo(iCase, 1) * 1e6, 0], '--');
    legendStr{iCase + 2 * Variable.nRxCases} = sprintf('WIPT (TS): Rx = %d', Variable.rx(iCase));
    hold on;
end
% optimal
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    plot([rateMimo(iCase, 9), maxRate(iCase)], [currentMimo(iCase, 9) * 1e6, 0], '-.');
    legendStr{iCase + 3 * Variable.nRxCases} = sprintf('WIPT + WIT: Rx = %d', Variable.rx(iCase));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);
%% Optimum strategy for MIMO (N = 4)
legendStr = cell(4 * Variable.nRxCases, 1);
figure('Name', sprintf('MIMO: subband = %d', Channel{iCase}.subband));
% WIPT
for iCase = 1: Variable.nRxCases
    plot(rateMimo(iCase, :), currentMimo(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): Rx = %d', Variable.rx(iCase));
    hold on;
end
% WIT
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    scatter(maxRate(iCase), 0);
    legendStr{iCase + Variable.nRxCases} = sprintf('WIT: Rx = %d', Variable.rx(iCase));
    hold on;
end
% time-sharing
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    plot([rateMimo(iCase, 1), maxRate(iCase)], [currentMimo(iCase, 1) * 1e6, 0], '--');
    legendStr{iCase + 2 * Variable.nRxCases} = sprintf('WIPT (TS): Rx = %d', Variable.rx(iCase));
    hold on;
end
% optimal
ax = gca;
ax.ColorOrderIndex = 1;
index = 6;
for iCase = 1: Variable.nRxCases
    index = index + 1;
    plot([rateMimo(iCase, index), maxRate(iCase)], [currentMimo(iCase, index) * 1e6, 0], '-.');
    legendStr{iCase + 3 * Variable.nRxCases} = sprintf('Optimal: Rx = %d', Variable.rx(iCase));
    hold on;
end
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    plot([rateMimo(iCase, 1), rateMimo(iCase, 4)], [currentMimo(iCase, 1), currentMimo(iCase, 4)] * 1e6, '-.');
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);
%% MISO
for iCase = 1: Variable.nRxCases
    for iChannel = 1: Variable.nChannels
        for iSample = 1: Variable.nSamples - 2
            if rateMiso(iCase, iChannel, iSample) ==  rateMiso(iCase, iChannel, iSample + 1)
                rateMiso(iCase, iChannel, iSample: Variable.nSamples) = NaN;
                currentMiso(iCase, iChannel, iSample: Variable.nSamples) = NaN;
                break;
            end
        end
    end
end
rateMisoAvg = squeeze(nanmean(rateMiso, 2));
currentMisoAvg = squeeze(nanmean(currentMiso, 2));
maxRateAvg = mean(maxRate, 2);

for iCase = 1: Variable.nRxCases
    for iChannel = 1: Variable.nChannels
        for iSample = 1: Variable.nSamples - 2
            if rateMiso(iCase, iChannel, iSample) ==  rateMiso(iCase, iChannel, iSample + 1)
                rateMiso(iCase, iChannel, iSample: Variable.nSamples) = NaN;
                currentMiso(iCase, iChannel, iSample: Variable.nSamples) = 0;
                break;
            end
        end
    end
end
rateMisoAvg = squeeze(nanmean(rateMiso, 2));
currentMisoAvg = squeeze(mean(currentMiso, 2));
maxRateAvg = mean(maxRate, 2);
%% Optimum MISO instance
legendStr = cell(4 * Variable.nTxCases, 1);
figure('Name', sprintf('MISO: subband = %d', Channel{iCase, iChannel}.subband));
% WIPT
for iCase = 1: Variable.nTxCases
    plot(squeeze(rateMiso(iCase, iChannel, :)), squeeze(currentMiso(iCase, iChannel, :)) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): Tx = %d', Variable.tx(iCase));
    hold on;
end
% WIT
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nTxCases
    scatter(maxRate(iCase, iChannel), 0);
    legendStr{iCase + Variable.nTxCases} = sprintf('WIT: Tx = %d', Variable.tx(iCase));
    hold on;
end
% time-sharing
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nTxCases
    plot([rateMiso(iCase, iChannel, 1), maxRate(iCase, iChannel)], [currentMiso(iCase, iChannel, 1) * 1e6, 0], '--');
    legendStr{iCase + 2 * Variable.nTxCases} = sprintf('WIPT (TS): Tx = %d', Variable.tx(iCase));
    hold on;
end

% optimal
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nRxCases
    plot([rateMiso(iCase, iChannel, 1), rateMiso(iCase, iChannel, 5)], [currentMiso(iCase, iChannel, 1), currentMiso(iCase, iChannel, 5)] * 1e6, '-.');
    legendStr{iCase + 3 * Variable.nTxCases} = sprintf('Optimum: Tx = %d', Variable.tx(iCase));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);