function [Channel] = channel_amplitude(Channel)
% Function:
%   - obtain the channel amplitude corresponding to the subband frequency
%
% InputArg(s):
%   - Channel.sampleFrequency: discrete frequency sample points
%   - Channel.tapDelay: tap delay
%   - Channel.tapGain: complex tap gain
%   - Channel.mode: choose from "flat" and "selective"
%
% OutputArg(s):
%   - Channel.amplitude: absolute multipath channel amplitude on the subbands
%
% Comments:
%   - for multipath flat and frequency-selective channels
%
% Author & Date: Yang (i@snowztail.com) - 29 Jun 19


v2struct(Channel, {'fieldNames', 'sampleFrequency', 'tapDelay', 'tapGain', 'mode'});

tx = size(tapDelay, 1);
subband = length(sampleFrequency);
centerFrequency = mean(sampleFrequency);
amplitude = zeros(subband, tx);

% sum taps to get absolute channel gain
if channelMode == "flat"
    for iTx = 1: tx
        amplitude(:, iTx) = repmat(abs(sum(tapGain(iTx, :) .* exp(-1i * 2 * pi * centerFrequency * tapDelay(iTx, :)))), subband, 1);
    end
elseif channelMode == "selective"
    for iTx = 1: tx
        for iSubband = 1: subband
            % sum paths to get complex channel gain
            amplitude(iSubband, iTx) = abs(sum(tapGain(iTx, :) .* exp(-1i * 2 * pi * sampleFrequency(iSubband) * tapDelay(iTx, :))));
        end
    end
end

Channel.amplitude = amplitude;

end

