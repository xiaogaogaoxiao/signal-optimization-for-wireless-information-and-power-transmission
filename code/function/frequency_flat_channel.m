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
%   - channelAmplitude: absolute value of channel frequency response
%
% Comments:
%   - flat fading
%   - assume transmit antennas are close enough and no phase shift
%   - the optimum phases of information and power waveforms for single-user systems are fixed as the negative phase of channel impulse response
%   - therefore, the optimization is all about the amplitudes and this function only returns the channel amplitude
%
% Author & Date: Yang (i@snowztail.com) - 21 Jun 19


frequencyResponse = zeros(nSubbands, nTxs);
for iTx = 1: nTxs
    % tapped-delay line by HIPERLAN/2 model B
    [tapDelay, tapGain] = hiperlan2_B();
    for iSubband = 1: nSubbands
        % sum paths to get complex channel gain
        frequencyResponse(iSubband, iTx) = sum(tapGain .* exp(-1i * 2 * pi * centerFrequency * tapDelay));
    end
end

% obtain the absolute value of channel impulse response
channelAmplitude = abs(frequencyResponse);

end

