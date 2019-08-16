%% Plot channel frequency response
Response = num2cell(repmat(Response, [Variable.nRxCases, 1]));
for iCase = 1: Variable.nRxCases
    Response{iCase}.tapDelay = Channel{iCase}.tapDelay;
    Response{iCase}.tapGain = Channel{iCase}.tapGain;
    % obtain the channel subbandAmplitude corresponding to the sampling frequency
    [Response{iCase}] = channel_response(Transceiver{iCase}, Response{iCase});
    % obtain dominant eigenvalue for each subband
    for iSubband = 1: length(Response{iCase}.sampleFrequency)
        Response{iCase}.dominantEigenVal(iSubband) = max(svd(squeeze(Response{iCase}.subbandAmplitude(iSubband, :, :))));
    end
end

legendStr = cell(2 * Variable.nRxCases, 1);
figure('Name', sprintf('Frequency response of the frequency-%s MIMO channel', Response{iCase}.fadingType));
for iCase = 1: Variable.nRxCases
    plot(Response{iCase}.basebandFrequency / 1e6, Response{iCase}.dominantEigenVal);
    hold on;
    plot(Response{iCase}.basebandFrequency(Response{iCase}.validIndex) / 1e6, Response{iCase}.dominantEigenVal(Response{iCase}.validIndex));
    hold on;
    legendStr{2 * iCase - 1} = [num2str(Transceiver{iCase}.tx) 'T' num2str(Transceiver{iCase}.rx) 'R: ' num2str(2.5 * Response{iCase}.bandwidth / 1e6) ' MHz'];
    legendStr{2 * iCase} = [num2str(Transceiver{iCase}.tx) 'T' num2str(Transceiver{iCase}.rx) 'R: ' num2str(Response{iCase}.bandwidth / 1e6) ' MHz'];
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Frequency [MHz]');
ylabel('Dominant eigenvalue');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);

clearvars iCase Response;
