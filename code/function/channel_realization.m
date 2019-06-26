function [channelAmplitude] = channel_realization(nSubbands, nTxs, centerFrequency, bandwidth, nRealizations, channelMode)
% Function:
%   - simulate representative multipath frequency-flat and frequency-selective channels by Monte-Carlo method
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - centerFrequency: center frequency of carriers
%   - bandwidth: available bandwidth
%   - nRealizations: number of channels to generate
%   - channelMode: choose from "flat" and "selective"
%
% OutputArg(s):
%   - channelAmplitude: absolute frequency response of typical flat or frequency-selective channel
%
% Comments:
%   - use average value as representative realization
%
% Author & Date: Yang (i@snowztail.com) - 26 Jun 19


channelAmplitude = zeros(nSubbands, nRealizations);
if channelMode == "flat"
    % simulate multipath channels based on tapped-delay line model
    for iRealization = 1: nRealizations
        [channelAmplitude(:, iRealization)] = frequency_flat_channel(nSubbands, nTxs, centerFrequency);
    end
elseif channelMode == "selective"
    for iRealization = 1: nRealizations
        [channelAmplitude(:, iRealization)] = frequency_selective_channel(nSubbands, nTxs, centerFrequency, bandwidth);
    end
end
channelAmplitude = mean(channelAmplitude, 2);

end

