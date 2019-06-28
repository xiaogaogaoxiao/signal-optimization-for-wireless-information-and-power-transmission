function [channelAmplitude] = frequency_flat_channel(nSubbands, nTxs, centerFrequency)
% Function:
%   - simulate a multipath frequency-flat channel based on tapped-delay line model
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - centerFrequency: center frequency of carriers
%
% OutputArg(s):
%   - channelAmplitude: absolute channel frequency response sampled on subbands
%
% Comments:
%   - flat fading
%   - assume transmit antennas are close enough and no phase shift
%   - the optimum phases of information and power waveforms for single-user systems are fixed as the negative phase of channel impulse response
%   - the optimization is all about the amplitudes
%
% Author & Date: Yang (i@snowztail.com) - 21 Jun 19


nSubbandCases = length(nSubbands);
channelAmplitude = cell(nSubbandCases, 1);

for iTx = 1: nTxs
    % tapped-delay line by HIPERLAN/2 model B
    [tapDelay, tapGain] = hiperlan2_B();
    for iSubbandCase = 1: nSubbandCases
        % sum paths to get complex channel gain
        channelAmplitude{iSubbandCase}(:, iTx) = abs(repmat(sum(tapGain .* exp(-1i * 2 * pi * centerFrequency * tapDelay)), nSubbands(iSubbandCase), 1));
    end
end

end

