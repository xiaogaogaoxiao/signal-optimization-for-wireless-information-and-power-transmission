initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
% obtain the channel amplitude corresponding to the carrier frequency
[Channel] = channel_response(Transceiver, Channel);
% save([pwd sprintf('/data/siso_%s_channel.mat',Channel.fadingType)], 'Channel');
% load([pwd sprintf('/data/siso_%s_channel.mat',Channel.fadingType)], 'Channel');
plot_response;
%% R-E region samples
ratePapr = zeros(Variable.nPaprCases, Variable.nSamples); currentPapr = zeros(Variable.nPaprCases, Variable.nSamples);
maxRate = zeros(Variable.nPaprCases, 1);
try
    for iCase = 1: Variable.nPaprCases
        Transceiver.papr = Variable.papr(iCase);
        % initialize algorithms
        [SolutionPapr, ~] = initialize_algorithm(Transceiver, Channel);
        for iSample = 1: Variable.nSamples
            Transceiver.rateThr = Variable.rateThr(iSample);
            [SolutionPapr] = wipt_papr(Transceiver, Channel, SolutionPapr);
            ratePapr(iCase, iSample) = SolutionPapr.rate; currentPapr(iCase, iSample) = SolutionPapr.current;
        end
    end
    [maxRate] = wit(Transceiver, Channel);
    ratePapr(:, Variable.nSamples + 1) = maxRate; currentPapr(:, Variable.nSamples + 1) = 0;
    for iCase = 1: Variable.nPaprCases
        [ratePapr(iCase, :), indexPapr] = sort(ratePapr(iCase, :)); currentPapr(iCase, :) = currentPapr(iCase, indexPapr);
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
%% R-E region plots
legendStr = cell(2 * Variable.nPaprCases + 1, 1);
figure('Name', sprintf('SISO: R-E region vs PAPR'));
% WIPT
for iCase = 1: Variable.nPaprCases
    plot(ratePapr(iCase, :), currentPapr(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): PAPR = %s dB', num2str(mag2db(Variable.papr(iCase))));
    hold on;
end
% WIT
scatter(maxRate, 0, 'black');
legendStr{Variable.nPaprCases + 1} = 'WIT: Maximum rate';
% time-sharing
ax = gca;
ax.ColorOrderIndex = 1;
for iCase = 1: Variable.nPaprCases
    plot([ratePapr(iCase, 1), maxRate], [currentPapr(iCase, 1) * 1e6, 0], '--');
    legendStr{iCase + Variable.nPaprCases + 1} = sprintf('WIPT (TS): PAPR = %s dB', num2str(mag2db(Variable.papr(iCase))));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');
save([pwd '/data/papr.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
