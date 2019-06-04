function [iMutual] = mutual_information(nSubband, nTx, sInfo, aChannel, pNoise, rho)
% Function:
%   - calculate the maximum achievable mutual information in Nats
%
% InputArg(s):
%   - nSubband: number of subbands/subcarriers
%   - nTx: number of transmit antennas
%   - sInfo: optimum information amplitude as CVX variable
%   - aChannel: amplitude of channel impulse response
%   - pNoise: noise power
%   - rho: power splitting ratio
%
% OutputArg(s):
%   - iMutual: mutual information in Nats
%
% Comments:
%   - notice the unit is Nat as there is no log2 in CVX
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19

iMutual = 0;
for n = 1: nSubband
    c = 0;
    for m0 = 1: nTx
        for m1 = 1: nTx
            c = c + (sInfo(n, m0) * aChannel(n, m0)) * (sInfo(n, m1) * aChannel(n, m1));
        end
    end
    iMutual = iMutual + log(1 + (1 - rho) / pNoise * c);
end
end

