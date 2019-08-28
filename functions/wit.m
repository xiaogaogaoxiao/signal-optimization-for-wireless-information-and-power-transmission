function [maxRate] = wit(Transceiver, Channel)
%WIT_MIMO Summary of this function goes here
%   Detailed explanation goes here

v2struct(Transceiver, {'fieldNames', 'rx', 'txPower', 'noisePower'});
v2struct(Channel, {'fieldNames', 'subband'});

if rx == 1
    lambda = Channel.subbandAmplitude(:) .^ 2;
else
    lambda = Channel.mimoAmplitude(:) .^ 2;
end
subbandPower = water_filling(lambda, 2 * txPower, noisePower);
% average rate per subband
maxRate = sum(log2(1 + subbandPower / noisePower.* lambda)) / subband;

end
