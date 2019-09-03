%% Plot channel frequency response
Response = num2cell(repmat(Response, [Variable.nTxCases, 1]));
for iCase = 1: Variable.nTxCases
    Response{iCase}.tapDelay = Channel{iCase}.tapDelay;
    Response{iCase}.tapGain = Channel{iCase}.tapGain;
    % obtain the channel subbandAmplitude corresponding to the sampling frequency
    [Response{iCase}] = channel_response(Transceiver{iCase}, Response{iCase});
end

for iCase = 1: Variable.nTxCases
    legendStr = cell(2 * Variable.nTxCases, 1);
    figure('Name', sprintf('Frequency response of the frequency-%s MISO channel', Response{iCase}.fadingType));
    for iTx = 1: Transceiver{iCase}.tx
        txAmplitude = Response{iCase}.subbandAmplitude(:, iTx);
        plot(Response{iCase}.basebandFrequency / 1e6, txAmplitude);
        hold on;
        plot(Response{iCase}.basebandFrequency(Response{iCase}.validIndex) / 1e6, txAmplitude(Response{iCase}.validIndex));
        hold on;
        legendStr{2 * iTx - 1} = ['Tx ' num2str(iTx) ': ' num2str(2.5 * Response{iCase}.bandwidth / 1e6) ' MHz'];
        legendStr{2 * iTx} = ['Tx ' num2str(iTx) ': ' num2str(Response{iCase}.bandwidth / 1e6) ' MHz'];
    end
    hold off;
    grid on; grid minor;
    legend(legendStr);
    xlabel('Frequency [MHz]');
    ylabel('Frequency response');
    xlim([-1.25, 1.25]);
    xticks(-1.25: 0.25: 1.25);
end


clearvars iCase Response;
