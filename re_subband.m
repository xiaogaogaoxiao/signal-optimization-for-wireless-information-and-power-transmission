initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
% save([pwd sprintf('/data/siso_%s_channel.mat',Channel.fadingType)], 'Channel');
% load([pwd sprintf('/data/siso_%s_channel.mat',Channel.fadingType)], 'Channel');
plot_response;
%% R-E region samples
rateDecoupling = zeros(Variable.nSubbandCases, Variable.nSamples); currentDecoupling = zeros(Variable.nSubbandCases, Variable.nSamples);
rateNoPowerWaveform = zeros(Variable.nSubbandCases, Variable.nSamples); currentNoPowerWaveform = zeros(Variable.nSubbandCases, Variable.nSamples);
try
    for iCase = 1: Variable.nSubbandCases
        Channel.subband = Variable.subband(iCase);
        Channel.sampleFrequency = Variable.sampleFrequency{iCase};
        Channel.gapFrequency = Variable.gapFrequency(iCase);
        % obtain the channel amplitude corresponding to the carrier frequency
        [Channel] = channel_response(Transceiver, Channel);
        % initialize algorithms
        [SolutionDecoupling, SolutionNoPowerWaveform] = initialize_algorithm(Transceiver, Channel);
        for iSample = 1: Variable.nSamples
            Transceiver.rateThr = Variable.rateThr(iSample);
            [SolutionDecoupling] = wipt_decoupling(Transceiver, Channel, SolutionDecoupling);
            [SolutionNoPowerWaveform] = wipt_no_power_waveform(Transceiver, Channel, SolutionNoPowerWaveform);
            rateDecoupling(iCase, iSample) = SolutionDecoupling.rate; currentDecoupling(iCase, iSample) = SolutionDecoupling.current;
            rateNoPowerWaveform(iCase, iSample) = SolutionNoPowerWaveform.rate; currentNoPowerWaveform(iCase, iSample) = SolutionNoPowerWaveform.current;
        end
        [maxRate(iCase)] = wit(Transceiver, Channel);
        rateDecoupling(iCase, Variable.nSamples + 1) = maxRate(iCase); currentDecoupling(iCase, Variable.nSamples + 1) = 0;
        rateNoPowerWaveform(iCase, Variable.nSamples + 1) = maxRate(iCase); currentNoPowerWaveform(iCase, Variable.nSamples + 1) = 0;
        [rateDecoupling(iCase, :), indexDecoupling] = sort(rateDecoupling(iCase, :)); currentDecoupling(iCase, :) = currentDecoupling(iCase, indexDecoupling);
        [rateNoPowerWaveform(iCase, :), indexNoPowerWaveform] = sort(rateNoPowerWaveform(iCase, :)); currentNoPowerWaveform(iCase, :) = currentNoPowerWaveform(iCase, indexNoPowerWaveform);
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
%% R-E region plots
legendStr = cell(3 * Variable.nSubbandCases, 1);
figure('Name', 'Superposed waveform');
% WIPT
for iCase = 1: Variable.nSubbandCases
    plot(rateDecoupling(iCase, :), currentDecoupling(iCase, :) * 1e6);
    legendStr{iCase} = sprintf('WIPT (PS): N = %d', Variable.subband(iCase));
    hold on;
end
ax = gca;
ax.ColorOrderIndex = 1;
% WIT
for iCase = 1: Variable.nSubbandCases
    scatter(maxRate(iCase), 0);
    legendStr{Variable.nSubbandCases + iCase} = sprintf('WIT: N = %d', Variable.subband(iCase));
    hold on;
end
ax = gca;
ax.ColorOrderIndex = 1;
% time-sharing
for iCase = 1: Variable.nSubbandCases
    plot([rateDecoupling(iCase, 1), maxRate(iCase)], [currentDecoupling(iCase, 1) * 1e6, 0], '--');
    legendStr{2 * Variable.nSubbandCases + iCase} = sprintf('WIPT (TS): N = %d', Variable.subband(iCase));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');

figure('Name', 'No power waveform');
for iCase = 1: Variable.nSubbandCases
    plot(rateNoPowerWaveform(iCase, :), currentNoPowerWaveform(iCase, :) * 1e6);
    hold on;
end
ax = gca;
ax.ColorOrderIndex = 1;
% WIT
for iCase = 1: Variable.nSubbandCases
    scatter(maxRate(iCase), 0);
    legendStr{Variable.nSubbandCases + iCase} = sprintf('WIT: N = %d', Variable.subband(iCase));
    hold on;
end
ax = gca;
ax.ColorOrderIndex = 1;
% time-sharing
for iCase = 1: Variable.nSubbandCases
    plot([rateNoPowerWaveform(iCase, 1), maxRate(iCase)], [currentNoPowerWaveform(iCase, 1) * 1e6, 0], '--');
    legendStr{2 * Variable.nSubbandCases + iCase} = sprintf('WIPT (TS): N = %d', Variable.subband(iCase));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');

save([pwd '/data/subband.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
