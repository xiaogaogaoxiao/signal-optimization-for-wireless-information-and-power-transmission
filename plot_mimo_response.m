%% Plot channel frequency response
Response.tapDelay = Channel.tapDelay;
Response.tapGain = Channel.tapGain;
% obtain the channel subbandAmplitude corresponding to the sampling frequency
[Response] = channel_response(Transceiver, Response);
% obtain dominant eigenvalue for each subband
for iSubband = 1: length(Response.sampleFrequency)
    Response.dominantEigenVal(iSubband) = max(svd(squeeze(Response.subbandAmplitude(iSubband, :, :))));
end

figure('Name', sprintf('Frequency response of the frequency-%s channel', Response.fadingType));
plot(Response.basebandFrequency / 1e6, Response.dominantEigenVal);
hold on;
plot(Response.basebandFrequency(Response.validIndex) / 1e6, Response.dominantEigenVal(Response.validIndex));
hold off;
grid on; grid minor;
legend([num2str(2.5 * Response.bandwidth / 1e6) ' MHz'], [num2str(Response.bandwidth / 1e6) ' MHz']);
xlabel('Frequency [MHz]');
ylabel('Dominant eigenvalue');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);

% clearvars iSubband Response;
