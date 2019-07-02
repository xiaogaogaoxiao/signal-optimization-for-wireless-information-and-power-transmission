function [frequencyResponse, basebandFrequency, tapDelay, tapGain] = frequency_response(nTxs, centerFrequency, bandwidth, channelMode)
% Function:
%   - obtain the channel frequency response based on HIPERLAN/2 model B
%
% InputArg(s):
%   - nTxs: number of transmit antennas
%   - centerFrequency: center frequency of carriers
%   - bandwidth: available bandwidth
%   - channelMode: choose from "flat" and "selective"
%
% OutputArg(s):
%   - frequencyResponse: absolute frequency response of a particular flat or frequency-selective channel
%   - basebandFrequency: baseband sampling frequency
%   - tapDelay: tap delay
%   - tapGain: complex tap gain
%
% Comments:
%   - assume the spacing between transmit antennas are negligible compared with transmit distance and no phase shift
%   - assume the spacing is large enough for independent fading
%   - randomness exists in each realization
%
% Author & Date: Yang (i@snowztail.com) - 26 Jun 19


tapDelay = zeros(nTxs, 18);
tapGain = zeros(nTxs, 18);
redundancy = 2.5;
gapFrequency = 1e4;

% sampling frequency
sampleFrequency = centerFrequency - redundancy * bandwidth / 2: gapFrequency: centerFrequency + redundancy * bandwidth / 2;

for iTx = 1: nTxs
    % tapped-delay line by HIPERLAN/2 model B
    [tapDelay(iTx, :), tapGain(iTx, :)] = hiperlan2_B();
end

[frequencyResponse] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode);
basebandFrequency = sampleFrequency - centerFrequency;

end

