function [channelAmplitude] = channel_amplitude(nSubbands, nTxs, centerFrequency, bandwidth, channelMode)
% Function:
%   - obtain the channel amplitude based on HIPERLAN/2 model B
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - centerFrequency: center frequency of carriers
%   - bandwidth: available bandwidth
%   - channelMode: choose from "flat" and "selective"
%
% OutputArg(s):
%   - channelAmplitude: absolute frequency response of certain flat or frequency-selective channel
%
% Comments:
%   - randomness exists in each realization
%
% Author & Date: Yang (i@snowztail.com) - 26 Jun 19


if channelMode == "flat"
    [channelAmplitude] = frequency_flat_channel(nSubbands, nTxs, centerFrequency);
elseif channelMode == "selective"
    [channelAmplitude] = frequency_selective_channel(nSubbands, nTxs, centerFrequency, bandwidth);
end

end

