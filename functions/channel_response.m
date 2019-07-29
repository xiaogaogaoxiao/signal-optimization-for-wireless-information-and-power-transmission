function [Channel] = channel_response(Transceiver, Channel)
% Function:
%   - obtain the channel amplitude and phase corresponding to the subband frequency
%
% InputArg(s):
%   - Transceiver.tx: number of transmit antenna
%   - Channel.centerFrequency: center frequency
%   - Channel.sampleFrequency: discrete frequency sample points
%   - Channel.tapDelay: tap delay
%   - Channel.tapGain: complex tap gain
%   - Channel.fadingType: choose from "flat" and "selective"
%
% OutputArg(s):
%   - Channel.subbandAmplitude: absolute multipath channel amplitude on the subbands
%   - Channel.subbandPhase: multipath channel phase on the subbands
%
% Comments:
%   - for multipath flat and frequency-selective channels
%
% Author & Date: Yang (i@snowztail.com) - 29 Jun 19


v2struct(Transceiver, {'fieldNames', 'tx'});
v2struct(Channel, {'fieldNames', 'centerFrequency', 'sampleFrequency', 'tapDelay', 'tapGain', 'fadingType'});

subband = length(sampleFrequency);
subbandGain = zeros(subband, tx);

% sum taps to get absolute channel gain
if fadingType == "flat"
    for iTx = 1: tx
        subbandGain(:, iTx) = repmat(sum(tapGain(iTx, :) .* exp(-1i * 2 * pi * centerFrequency * tapDelay)), subband, 1);
    end
elseif fadingType == "selective"
    for iTx = 1: tx
        for iSubband = 1: subband
            subbandGain(iSubband, iTx) = sum(tapGain(iTx, :) .* exp(-1i * 2 * pi * sampleFrequency(iSubband) * tapDelay));
        end
    end
end

Channel.subbandAmplitude = abs(subbandGain);
Channel.subbandPhase = angle(subbandGain);

end

