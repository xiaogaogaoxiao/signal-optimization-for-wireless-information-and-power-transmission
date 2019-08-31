initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel and R-E region samples
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
rateMiso = zeros(Variable.nRxCases, Variable.nChannels, Variable.nSamples); currentMiso = zeros(Variable.nRxCases, Variable.nChannels, Variable.nSamples);
maxRate = zeros(Variable.nRxCases, Variable.nChannels);
% try
    for iCase = 1: Variable.nRxCases
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
rateMisoAvg = squeeze(mean(rateMiso, 2)); currentMisoAvg = squeeze(mean(currentMiso, 2));
maxRateAvg = mean(maxRate, 2);
%% R-E region plots
legendStr = cell(3 * Variable.nTxCases, 1);
figure('Name', sprintf('MISO: subband = %d', Channel{iCase, iChannel}.subband));
% WIPT
for iCase = 1: Variable.nTxCases
    plot(rateMisoAvg(iCase, :), currentMisoAvg(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): Rx = %d', Variable.tx(iCase));
    hold on;
end
% WIT
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nTxCases
    scatter(maxRateAvg(iCase), 0);
    legendStr{iCase + Variable.nTxCases} = sprintf('WIT: Rx = %d', Variable.tx(iCase));
    hold on;
end
% time-sharing
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nTxCases
    plot([rateMisoAvg(iCase, 1), maxRateAvg(iCase)], [currentMisoAvg(iCase, 1) * 1e6, 0], '--');
    legendStr{iCase + 2 * Variable.nTxCases} = sprintf('WIPT (TS): Rx = %d', Variable.tx(iCase));
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);
save([pwd '/data/miso.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
