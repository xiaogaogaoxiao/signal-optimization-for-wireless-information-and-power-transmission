initialize; config;
% Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
% plot_response;
% obtain the channel amplitude corresponding to the carrier frequency
[Channel] = channel_response(Transceiver, Channel);
save([pwd '/data/channel.mat']);
% load([pwd '/data/channel.mat']);
%% R-E region samples
ratePapr = zeros(Variable.nPaprCases, Variable.nSamples); currentPapr = zeros(Variable.nPaprCases, Variable.nSamples);
% try
    for iCase = 1: Variable.nPaprCases
        Transceiver.papr = Variable.papr(iCase);
        % initialize algorithms
        [SolutionPapr, ~] = initialize_algorithm(Transceiver, Channel);
        for iSample = 1: Variable.nSamples
            Transceiver.rateThr = Variable.rateThr(iSample);
            [SolutionPapr] = wipt_papr(Transceiver, Channel, SolutionPapr);
            ratePapr(iCase, iSample) = SolutionPapr.rate; currentPapr(iCase, iSample) = SolutionPapr.current;
            % invalid solution cannot be used for iterations
            if isnan(ratePapr(iCase, iSample))
                [SolutionPapr, ~] = initialize_algorithm(Transceiver, Channel);
            end
        end
    end
% catch
%     Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
% end
%% R-E region plots
legendStr = cell(Variable.nPaprCases);
figure('Name', sprintf('R-E region vs PAPR'));
for iCase = 1: Variable.nPaprCases
    plot(ratePapr(iCase, :), currentPapr(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('PAPR = %d dB', mag2db(Variable.papr(iCase)));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]')
save('data_papr.mat');
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
