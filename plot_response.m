%% Plot channel frequency response
Response.tapDelay = Channel.tapDelay;
Response.tapGain = Channel.tapGain;
% obtain the channel subbandAmplitude corresponding to the sampling frequency
[Response] = channel_response(Transceiver, Response);
legendStr = cell(2 * Transceiver.tx, 1);
figure('Name', sprintf('Frequency response of the frequency-%s channel', Response.fadingType));
for iTx = 1: Transceiver.tx
    plot(Response.basebandFrequency / 1e6, Response.subbandAmplitude(:, iTx));
    legendStr{2 * iTx - 1} = ['Tx ' num2str(iTx) ': ' num2str(2.5 * Response.bandwidth / 1e6) ' MHz'];
    hold on;
    plot(Response.basebandFrequency(Response.validIndex) / 1e6, Response.subbandAmplitude(Response.validIndex, iTx));
    legendStr{2 * iTx} = ['Tx ' num2str(iTx) ': ' num2str(Response.bandwidth / 1e6) ' MHz'];
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr);
xlabel('Frequency [MHz]');
ylabel('Frequency response');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);
yticks(0: 0.2: 10);

clearvars Response;
