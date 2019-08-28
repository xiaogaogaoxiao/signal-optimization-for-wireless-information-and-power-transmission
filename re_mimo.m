initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel and R-E region samples
Transceiver = num2cell(repmat(Transceiver, [Variable.nRxCases, 1]));
Channel = num2cell(repmat(Channel, [Variable.nRxCases, 1]));
for iCase = 1: Variable.nRxCases
    Transceiver{iCase}.rx = Variable.rx(iCase);
    Transceiver{iCase}.weight = Variable.weight{iCase};
    % generate the tap delay and gains based on HIPERLAN/2 model B
    [Channel{iCase}] = hiperlan2_B(Transceiver{iCase}, Channel{iCase});
    % obtain the channel amplitude corresponding to the carrier frequency
    [Channel{iCase}] = channel_response(Transceiver{iCase}, Channel{iCase});
    % decompose channel matrix
    [Transceiver{iCase}, Channel{iCase}] = preprocessing(Transceiver{iCase}, Channel{iCase});
end
% save([pwd sprintf('/data/mimo_%s_channel.mat',Channel{iCase}.fadingType)], 'Channel', 'Transceiver');
% load([pwd sprintf('/data/mimo_%s_channel.mat',Channel{iCase}.fadingType)], 'Channel', 'Transceiver');
plot_mimo_response;
%% R-E region samples
rateMimo = zeros(Variable.nRxCases, Variable.nSamples); currentMimo = zeros(Variable.nRxCases, Variable.nSamples);
maxRate = zeros(Variable.nRxCases, 1);
try
    for iCase = 1: Variable.nRxCases
        % initialize algorithms
        [SolutionMimo, ~] = initialize_algorithm(Transceiver{iCase}, Channel{iCase});
        for iSample = 1: Variable.nSamples
            Transceiver{iCase}.rateThr = Variable.rateThr(iSample);
            [SolutionMimo] = wipt_mimo(Transceiver{iCase}, Channel{iCase}, SolutionMimo);
            rateMimo(iCase, iSample) = SolutionMimo.rate; currentMimo(iCase, iSample) = SolutionMimo.current;
        end
        [maxRate(iCase)] = wit(Transceiver{iCase}, Channel{iCase});
        rateMimo(iCase, Variable.nSamples + 1) = maxRate(iCase); currentMimo(iCase, Variable.nSamples + 1) = 0;
        [rateMimo(iCase, :), indexDecoupling] = sort(rateMimo(iCase, :)); currentMimo(iCase, :) = currentMimo(iCase, indexDecoupling);
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
%% R-E region plots
legendStr = cell(3 * Variable.nRxCases, 1);
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
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
xticks(0: 1: 15);
save([pwd '/data/mimo.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
