%% Plot channel frequency response
figure('Name', sprintf('Frequency response of the frequency-%s channel', Channel.fadingType));
plot(Channel.basebandFrequency / 1e6, Channel.amplitude);
hold on;
plot(Channel.basebandFrequency(Channel.validIndex) / 1e6, Channel.amplitude(Channel.validIndex));
grid on; grid minor;
legend([num2str(2.5 * Channel.bandwidth / 1e6) ' MHz'], [num2str(Channel.bandwidth / 1e6) ' MHz']);
xlabel('Frequency [MHz]');
ylabel('Frequency response');
xlim([-1.25, 1.25]);
xticks(-1.25: 0.25: 1.25);
yticks(0: 0.2: 10);
