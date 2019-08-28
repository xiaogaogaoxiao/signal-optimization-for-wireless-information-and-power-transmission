function [maxRate] = wit(Transceiver, Channel)
% Function:
%   - calculate the maximum achievable rate based on water-filling
%
% InputArg(s):
%   - Transceiver.tx: number of transmit antenna
%   - Transceiver.rx: number of receive antenna
%   - Transceiver.txPower: average transmit power
%   - Transceiver.noisePower: average noise power
%   - Channel.subband: number of subbands (subcarriers)
%
% OutputArg(s):
%   - maxRate: the maximum achievable rate
%
% Comments:
%   - for SISO, MISO and MIMO
%
% Author & Date: Yang (i@snowztail.com) - 28 Aug 19

v2struct(Transceiver, {'fieldNames', 'tx', 'rx', 'txPower', 'noisePower'});
v2struct(Channel, {'fieldNames', 'subband'});

if tx == 1 && rx == 1
    % SISO
    lambda = Channel.subbandAmplitude(:) .^ 2;
elseif tx > 1 && rx > 1
    % MIMO
    lambda = Channel.mimoAmplitude(:) .^ 2;
else
    % MISO
    lambda = vecnorm(Channel.subbandAmplitude, 2, 2) .^ 2;
end

subbandPower = water_filling(lambda, 2 * txPower, noisePower);
% average rate per subband
maxRate = sum(log2(1 + subbandPower / noisePower.* lambda)) / subband;

end
