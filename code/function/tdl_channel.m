function [hChannel] = tdl_channel(nSubband, nTx, fCarrier)
% Function:
%   - simulate a multipath channel based on tapped-delay line model
%
% InputArg(s):
%   - nSubband: number of subbands/subcarriers
%   - nTx: number of transmit antenna
%   - fCarrier: carrier frequency
%
% OutputArg(s):
%   - hChannel: impluse response of a multipath channel
%
% Comments:
%   - assume no phase shift between transmit antennas
%
% Author & Date: Yang (i@snowztail.com) - 02 Jun 19


hChannel = zeros(nSubband, nTx);

for iTx = 1: nTx
    % tapped-delay line with HIPERLAN/2-B model
    [dTap, gTap] = hiperlan_2B();
    for iSubband = 1: nSubband
        % complex channel gain as a sum of paths
        hChannel(iSubband, iTx) = sum(gTap .* exp(-1i * 2 * pi * fCarrier(iSubband) * dTap));
    end
end
end

