function [impulseResponse] = impulse_response(nSubbands, nTxs, carrierFreq)
% Function:
%   - simulate a multipath channel based on tapped-delay line model
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - carrierFreq: carrier frequency
%
% OutputArg(s):
%   - impulseResponse: channel impluse response
%
% Comments:
%   - assume transmit antennas are close enough and no phase shift
%
% Author & Date: Yang (i@snowztail.com) - 02 Jun 19


impulseResponse = zeros(nSubbands, nTxs);
for iTx = 1: nTxs
    % tapped-delay line by HIPERLAN/2 model B
    [tapDelay, tapGain] = hiperlan2_B();
    for iSubband = 1: nSubbands
        % sum paths to get complex channel gain
        impulseResponse(iSubband, iTx) = sum(tapGain .* exp(-1i * 2 * pi * carrierFreq(iSubband) * tapDelay));
    end
end

end

