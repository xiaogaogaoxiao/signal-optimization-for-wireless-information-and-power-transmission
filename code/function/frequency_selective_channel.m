function [channelAmplitude] = frequency_selective_channel(nSubbands, nTxs, centerFrequency, bandwidth)
% Function:
%   - simulate a multipath frequency-selective channel based on tapped-delay line model
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - centerFrequency: center frequency of carriers
%   - bandwidth: available bandwidth
%
% OutputArg(s):
%   - channelAmplitude: absolute channel frequency response sampled on subbands
%
% Comments:
%   - frequency-selective fading
%   - assume transmit antennas are close enough and no phase shift
%   - the optimum phases of information and power waveforms for single-user systems are fixed as the negative phase of channel impulse response
%   - the optimization is all about the amplitudes
%
% Author & Date: Yang (i@snowztail.com) - 02 Jun 19


% channelAmplitude = zeros(nSubbands, nTxs);
% % gap frequency
% gapFrequency = bandwidth / nSubbands;
% % carrier frequency
% carrierFrequency = centerFrequency - (nSubbands - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbands - 1) / 2 * gapFrequency;
% for iTx = 1: nTxs
%     % tapped-delay line by HIPERLAN/2 model B
%     [tapDelay, tapGain] = hiperlan2_B();
%     for iSubband = 1: nSubbands
%         % sum paths to get complex channel gain
%         channelAmplitude(iSubband, iTx) = sum(tapGain .* exp(-1i * 2 * pi * carrierFrequency(iSubband) * tapDelay));
%     end
% end

nSubbandCases = length(nSubbands);
channelAmplitude = cell(nSubbandCases, 1);

for iTx = 1: nTxs
    % tapped-delay line by HIPERLAN/2 model B
    [tapDelay, tapGain] = hiperlan2_B();
    for iSubbandCase = 1: nSubbandCases
        % gap frequency
        gapFrequency = bandwidth / nSubbands(iSubbandCase);
        % carrier frequency
        carrierFrequency = centerFrequency - (nSubbands(iSubbandCase) - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbands(iSubbandCase) - 1) / 2 * gapFrequency;
        for iSubband = 1: nSubbands(iSubbandCase)
            % sum paths to get complex channel gain
            channelAmplitude{iSubbandCase}(iSubband, iTx) = abs(sum(tapGain .* exp(-1i * 2 * pi * carrierFrequency(iSubband) * tapDelay)));
        end
    end
end

end

