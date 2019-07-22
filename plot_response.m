%% Plot channel frequency response
Response.tapDelay = Channel.tapDelay;
Response.tapGain = Channel.tapGain; 
% obtain the channel subbandAmplitude corresponding to the sampling frequency
[Response] = channel_amplitude(Transceiver, Response);

figure('Name', sprintf('Frequency response of the frequency-%s channel', Response.fadingType));
plot(Response.basebandFrequency / 1e6, Response.subbandAmplitude);
hold on;
plot(Response.basebandFrequency(Response.validIndex) / 1e6, Response.subbandAmplitude(Response.validIndex));
grid on; grid minor;
legend([num2str(2.5 * Response.bandwidth / 1e6) ' MHz'], [num2str(Response.bandwidth / 1e6) ' MHz']);
xlabel('Frequency [MHz]');
ylabel('Frequency response');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);
yticks(0: 0.2: 10);

clearvars Response;
