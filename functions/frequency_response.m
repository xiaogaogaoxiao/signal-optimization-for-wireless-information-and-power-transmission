function [frequencyResponse, basebandFrequency] = sampli(Channel)
% Function:
%   - obtain the channel frequency response based on HIPERLAN/2 model B
%
% InputArg(s):
%   - tapDelay: tap delay
%   - tapGain: complex tap gain
%   - centerFrequency: center frequency of carriers
%   - bandwidth: available bandwidth
%   - mode: choose from "flat" and "selective"
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


v2struct(Channel, {'fieldNames', 'tapDelay', 'tapGain', 'centerFrequency', 'bandwidth', 'mode'});

% parameters for channel plot
redundancy = 2.5;
gapFrequency = 1e4;

Channel.sampleFrequency = centerFrequency - redundancy * bandwidth / 2: gapFrequency: centerFrequency + redundancy * bandwidth / 2;

end

