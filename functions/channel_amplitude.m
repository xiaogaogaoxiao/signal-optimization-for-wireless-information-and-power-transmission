function [channelAmplitude] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode)
% Function:
%   - obtain the channel amplitude corresponding to the subband frequency
%
% InputArg(s):
%   - sampleFrequency: subband frequency
%   - tapDelay: tap delay
%   - tapGain: complex tap gain
%   - channelMode: choose from "flat" and "selective"
%
% OutputArg(s):
%   - channelAmplitude: absolute multipath channel amplitude on the subbands
%
% Comments:
%   - for multipath flat and frequency-selective channels
%
% Author & Date: Yang (i@snowztail.com) - 29 Jun 19


nTxs = size(tapDelay, 1);
nSubbands = length(sampleFrequency);
centerFrequency = mean(sampleFrequency);
channelAmplitude = zeros(nSubbands, nTxs);

% sum taps to get absolute channel gain
if channelMode == "flat"
    for iTx = 1: nTxs
        channelAmplitude(:, iTx) = repmat(abs(sum(tapGain(iTx, :) .* exp(-1i * 2 * pi * centerFrequency * tapDelay(iTx, :)))), nSubbands, 1);
    end
elseif channelMode == "selective"
    for iTx = 1: nTxs
        for iSubband = 1: nSubbands
            % sum paths to get complex channel gain
            channelAmplitude(iSubband, iTx) = abs(sum(tapGain(iTx, :) .* exp(-1i * 2 * pi * sampleFrequency(iSubband) * tapDelay(iTx, :))));
        end
    end
end

end

