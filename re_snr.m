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
rateDecoupling = zeros(Variable.nSnrCases, Variable.nSamples); currentDecoupling = zeros(Variable.nSnrCases, Variable.nSamples);
rateLowerBound = zeros(Variable.nSnrCases, Variable.nSamples); currentLowerBound = zeros(Variable.nSnrCases, Variable.nSamples);
rateNoPowerWaveform = zeros(Variable.nSnrCases, Variable.nSamples); currentNoPowerWaveform = zeros(Variable.nSnrCases, Variable.nSamples);
maxRate = zeros(Variable.nSnrCases, 1);
try
    for iCase = 1: Variable.nSnrCases
        Transceiver.snrDb = Variable.snrDb(iCase);
        Transceiver.noisePower = Variable.noisePower(iCase);
        % initialize algorithms
        [SolutionDecoupling, SolutionNoPowerWaveform] = initialize_algorithm(Transceiver, Channel);
        SolutionLowerBound = SolutionDecoupling;
        for iSample = 1: Variable.nSamples
            Transceiver.rateThr = Variable.rateThr(iSample);
            [SolutionDecoupling] = wipt_decoupling(Transceiver, Channel, SolutionDecoupling);
            [SolutionLowerBound] = wipt_lower_bound(Transceiver, Channel, SolutionLowerBound);
            [SolutionNoPowerWaveform] = wipt_no_power_waveform(Transceiver, Channel, SolutionNoPowerWaveform);
            rateDecoupling(iCase, iSample) = SolutionDecoupling.rate; currentDecoupling(iCase, iSample) = SolutionDecoupling.current;
            rateLowerBound(iCase, iSample) = SolutionLowerBound.rate; currentLowerBound(iCase, iSample) = SolutionLowerBound.current;
            rateNoPowerWaveform(iCase, iSample) = SolutionNoPowerWaveform.rate; currentNoPowerWaveform(iCase, iSample) = SolutionNoPowerWaveform.current;
        end
        [maxRate(iCase)] = wit(Transceiver, Channel);
        rateDecoupling(iCase, Variable.nSamples + 1) = maxRate(iCase); currentDecoupling(iCase, Variable.nSamples + 1) = 0;
        rateLowerBound(iCase, Variable.nSamples + 1) = maxRate(iCase); currentLowerBound(iCase, Variable.nSamples + 1) = 0;
        rateNoPowerWaveform(iCase, Variable.nSamples + 1) = maxRate(iCase); currentNoPowerWaveform(iCase, Variable.nSamples + 1) = 0;
        [rateDecoupling(iCase, :), indexDecoupling] = sort(rateDecoupling(iCase, :)); currentDecoupling(iCase, :) = currentDecoupling(iCase, indexDecoupling);
        [rateLowerBound(iCase, :), indexLowerBound] = sort(rateLowerBound(iCase, :)); currentLowerBound(iCase, :) = currentLowerBound(iCase, indexLowerBound);
        [rateNoPowerWaveform(iCase, :), indexNoPowerWaveform] = sort(rateNoPowerWaveform(iCase, :)); currentNoPowerWaveform(iCase, :) = currentNoPowerWaveform(iCase, indexNoPowerWaveform);
    end
catch
    Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
end
%% R-E region plots
for iCase = 1: Variable.nSnrCases
    figure('Name', sprintf('SISO: SNR = %d dB', Variable.snrDb(iCase)));
    % WIPT
    plot(rateDecoupling(iCase, :), currentDecoupling(iCase, :) * 1e6);
    hold on;
    plot(rateLowerBound(iCase, :), currentLowerBound(iCase, :) * 1e6);
    hold on;
    plot(rateNoPowerWaveform(iCase, :), currentNoPowerWaveform(iCase, :) * 1e6);
    hold on;
    % WIT
    scatter(maxRate(iCase), 0, 'black');
    % time-sharing
    plot([rateDecoupling(iCase, 1), maxRate(iCase)], [currentDecoupling(iCase, 1) * 1e6, 0], 'k--');
    hold off;
    grid on; grid minor;
    legend('WIPT (PS): Superposed waveform', 'WIPT (PS): Lower bound', 'WIPT (PS): No power waveform', 'WIT: Maximum rate', 'WIPT (TS): Superposed waveform');
    xlabel('Rate [bps/Hz]');
    ylabel('I_{DC} [\muA]');
end
save([pwd '/data/snr.mat']);
Push.pushNote(Push.Devices, 'MATLAB Assist', 'Job''s done!');
