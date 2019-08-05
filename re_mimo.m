initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel and R-E region samples
rateMimo = zeros(Variable.nRxCases, Variable.nSamples); currentMimo = zeros(Variable.nRxCases, Variable.nSamples);
try
    for iCase = 1: Variable.nRxCases
        Transceiver.rx = Variable.rx(iCase);
        Transceiver.weight = Variable.weight{iCase};
        % generate the tap delay and gains based on HIPERLAN/2 model B
        [Channel] = hiperlan2_B(Transceiver, Channel);
        plot_response;
        % obtain the channel amplitude corresponding to the carrier frequency
        [Channel] = channel_response(Transceiver, Channel);
        % reshape channel matrix to 2-D
        [Transceiver, Channel] = preprocessing(Transceiver, Channel);
        % initialize algorithms
        [SolutionMimo, ~] = initialize_algorithm(Transceiver, Channel);
        for iSample = 1: Variable.nSamples
            Transceiver.rateThr = Variable.rateThr(iSample);
            [SolutionMimo] = wipt_mimo(Transceiver, Channel, SolutionMimo);
            rateMimo(iCase, iSample) = SolutionMimo.rate; currentMimo(iCase, iSample) = SolutionMimo.current;
            % invalid solution cannot be used for iterations
            if isnan(rateMimo(iCase, iSample))
                [SolutionMimo, ~] = initialize_algorithm(Transceiver, Channel);
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
