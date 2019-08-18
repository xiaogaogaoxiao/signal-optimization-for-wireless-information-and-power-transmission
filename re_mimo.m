initialize; config;
% Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
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
plot_mimo_response;
% save([pwd sprintf('/data/mimo_%s_channel.mat',Channel{1}.fadingType)], 'Channel', 'Transceiver');
% load([pwd sprintf('/data/mimo_%s_channel.mat',Channel{1}.fadingType)], 'Channel', 'Transceiver');
%% R-E region samples
rateMimo = zeros(Variable.nRxCases, Variable.nSamples); currentMimo = zeros(Variable.nRxCases, Variable.nSamples);
try
    for iCase = 1: Variable.nRxCases
        % initialize algorithms
        [SolutionMimo, ~] = initialize_algorithm(Transceiver{iCase}, Channel{iCase});
        for iSample = 1: Variable.nSamples
            Transceiver{iCase}.rateThr = Variable.rateThr(iSample);
            [SolutionMimo] = wipt_mimo(Transceiver{iCase}, Channel{iCase}, SolutionMimo);
            rateMimo(iCase, iSample) = SolutionMimo.rate; currentMimo(iCase, iSample) = SolutionMimo.current;
            % invalid solution cannot be used for iterations
            if isnan(rateMimo(iCase, iSample))
                [SolutionMimo, ~] = initialize_algorithm(Transceiver{iCase}, Channel{iCase});
            end
        end
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
%% R-E region plots
legendStr = cell(Variable.nRxCases, 1);
figure('Name', sprintf('R-E region vs number of rectennas'));
for iCase = 1: Variable.nRxCases
    plot(rateMimo(iCase, :), currentMimo(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('Rx = %d', Variable.rx(iCase));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')
save([pwd '/data/mimo.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
