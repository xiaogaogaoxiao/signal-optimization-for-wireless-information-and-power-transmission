initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
Transceiver = num2cell(repmat(Transceiver, [Variable.nTxCases, 1]));
Channel = num2cell(repmat(Channel, [Variable.nTxCases, Variable.nChannels]));
for iCase = 1: Variable.nTxCases
    Transceiver{iCase}.tx = Variable.tx(iCase);
    for iChannel = 1: Variable.nChannels
        % generate the tap delay and gains based on HIPERLAN/2 model B
        [Channel{iCase, iChannel}] = hiperlan2_B(Transceiver{iCase}, Channel{iCase, iChannel});
        % obtain the channel amplitude corresponding to the carrier frequency
        [Channel{iCase, iChannel}] = channel_response(Transceiver{iCase}, Channel{iCase, iChannel});
    end
end
% save([pwd sprintf('/data/miso_%s_channel.mat',Channel{iCase, iCase}.fadingType)], 'Channel', 'Transceiver');
% load([pwd sprintf('/data/miso_%s_channel.mat',Channel{iCase, iCase}.fadingType)], 'Channel', 'Transceiver');
%% R-E region samples
rateMiso = zeros(Variable.nTxCases, Variable.nChannels, Variable.nSamples); currentMiso = zeros(Variable.nTxCases, Variable.nChannels, Variable.nSamples);
maxRate = zeros(Variable.nTxCases, Variable.nChannels);
try
    for iCase = 1: Variable.nTxCases
        for iChannel = 1: Variable.nChannels
            % initialize algorithms
            [SolutionMiso, ~] = initialize_algorithm(Transceiver{iCase}, Channel{iCase, iChannel});
            for iSample = 1: Variable.nSamples
                Transceiver{iCase}.rateThr = Variable.rateThr(iSample);
                [SolutionMiso] = wipt_decoupling(Transceiver{iCase}, Channel{iCase, iChannel}, SolutionMiso);
                rateMiso(iCase, iChannel, iSample) = SolutionMiso.rate; currentMiso(iCase, iChannel, iSample) = SolutionMiso.current;
            end
            [maxRate(iCase, iChannel)] = wit(Transceiver{iCase}, Channel{iCase, iChannel});
            rateMiso(iCase, iChannel, Variable.nSamples + 1) = maxRate(iCase, iChannel); currentMiso(iCase, iChannel, Variable.nSamples + 1) = 0;
            [rateMiso(iCase, iChannel, :), indexDecoupling] = sort(rateMiso(iCase, iChannel, :)); currentMiso(iCase, iChannel, :) = currentMiso(iCase, iChannel, indexDecoupling);
        end
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
rateMisoAvg = squeeze(nanmean(rateMiso, 2)); currentMisoAvg = squeeze(nanmean(currentMiso, 2));
maxRateAvg = mean(maxRate, 2);
%% R-E region instance
legendStr = cell(3 * Variable.nTxCases, 1);
figure('Name', sprintf('MISO instance: subband = %d', Channel{iCase, iChannel}.subband));
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
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);
%% R-E region average plot (to improve)
legendStr = cell(3 * Variable.nTxCases, 1);
figure('Name', sprintf('MISO average: subband = %d', Channel{iCase, iChannel}.subband));
% WIPT
for iCase = 1: Variable.nTxCases
    plot(rateMisoAvg(iCase, :), currentMisoAvg(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): Tx = %d', Variable.tx(iCase));
    hold on;
end
% WIT
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nTxCases
    scatter(maxRateAvg(iCase), 0);
    legendStr{iCase + Variable.nTxCases} = sprintf('WIT: Tx = %d', Variable.tx(iCase));
    hold on;
end
% time-sharing
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nTxCases
    plot([rateMisoAvg(iCase, 1), maxRateAvg(iCase)], [currentMisoAvg(iCase, 1) * 1e6, 0], '--');
    legendStr{iCase + 2 * Variable.nTxCases} = sprintf('WIPT (TS): Tx = %d', Variable.tx(iCase));
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);
save([pwd '/data/miso.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
%% Rate and current distribution
figure('Name', sprintf('MISO rate distribution: subband = %d', Channel{iCase, iChannel}.subband));
legendStr = cell(Variable.nTxCases, 1);
for iCase = 1: Variable.nTxCases
    cdfplot(rateMiso(iCase, :, end));
    legendStr{iCase} = sprintf('WIPT (PS): Tx = %d', Variable.tx(iCase));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'se');
xlabel('Rate [bps/Hz]');
ylabel('Probability');
xticks(0: 1: 15);
figure('Name', sprintf('MISO current distribution: subband = %d', Channel{iCase, iChannel}.subband));
for iCase = 1: Variable.nTxCases
    cdfplot(currentMiso(iCase, :, 1) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'se');
xlabel('I_{DC} [\muA]');
ylabel('Probability');