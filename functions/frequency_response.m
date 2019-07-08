function [frequencyResponse, basebandFrequency] = frequency_response(tapDelay, tapGain, centerFrequency, bandwidth, channelMode)
% Function:
%   - obtain the channel frequency response based on HIPERLAN/2 model B
%
% InputArg(s):
%   - centerFrequency: center frequency of carriers
%   - bandwidth: available bandwidth
%   - channelMode: choose from "flat" and "selective"
%   - tapDelay: tap delay
%   - tapGain: complex tap gain
%
% OutputArg(s):
%   - frequencyResponse: absolute frequency response of a particular flat or frequency-selective channel
%   - basebandFrequency: baseband sampling frequency
%
% Comments:
%   - assume the spacing between transmit antennas are negligible compared with transmit distance and no phase shift
%   - assume the spacing is large enough for independent fading
%   - randomness exists in each realization
%
% Author & Date: Yang (i@snowztail.com) - 26 Jun 19


redundancy = 2.5;
gapFrequency = 1e4;

% sampling frequency
sampleFrequency = centerFrequency - redundancy * bandwidth / 2: gapFrequency: centerFrequency + redundancy * bandwidth / 2;

[frequencyResponse] = channel_amplitude(sampleFrequency, tapDelay, tapGain, channelMode);
basebandFrequency = sampleFrequency - centerFrequency;

end

