%% Plot channel frequency response
% obtain the channel subbandAmplitude corresponding to the sampling frequency
[Channel] = channel_amplitude(Transceiver, Channel);

figure('Name', sprintf('Frequency response of the frequency-%s channel', Channel.fadingType));
plot(Channel.basebandFrequency / 1e6, Channel.subbandAmplitude);
hold on;
plot(Channel.basebandFrequency(Channel.validIndex) / 1e6, Channel.subbandAmplitude(Channel.validIndex));
grid on; grid minor;
legend([num2str(2.5 * Channel.bandwidth / 1e6) ' MHz'], [num2str(Channel.bandwidth / 1e6) ' MHz']);
xlabel('Frequency [MHz]');
ylabel('Frequency response');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);
yticks(0: 0.2: 10);

Channel = rmfield(Channel, {'sampleFrequency', 'subbandAmplitude', 'validIndex'});
