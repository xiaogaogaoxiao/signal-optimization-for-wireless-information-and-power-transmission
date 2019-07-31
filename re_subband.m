initialize; config;
Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% Channel
% generate the tap delay and gains based on HIPERLAN/2 model B
[Channel] = hiperlan2_B(Transceiver, Channel);
plot_response;
save([pwd '/data/channel.mat']);
% load([pwd '/data/channel.mat']);
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
            % invalid solution cannot be used for iterations
            if isnan(rateDecoupling(iCase, iSample))
                [SolutionDecoupling, ~] = initialize_algorithm(Transceiver, Channel);
            end
            if isnan(rateNoPowerWaveform(iCase, iSample))
                [~, SolutionNoPowerWaveform] = initialize_algorithm(Transceiver, Channel);
            end
        end
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
%% R-E region plots
figure('Name', 'Superposed waveforms');
for iCase = 1: Variable.nSubbandCases
    plot(rateDecoupling(iCase, :), currentDecoupling(iCase, :) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(cellstr(num2str(Variable.subband', 'N = %d')));
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');

figure('Name', 'No power waveform');
for iCase = 1: Variable.nSubbandCases
    plot(rateNoPowerWaveform(iCase, :), currentNoPowerWaveform(iCase, :) * 1e6);
    hold on;
end
hold off;
grid on; grid minor;
legend(cellstr(num2str(Variable.subband', 'N = %d')));
xlabel('Rate [bps/Hz]');
ylabel('I_{DC} [\muA]');

save('data_subband.mat');
pushbullet.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
