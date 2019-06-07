function [iMutual, gn, nTermGn] = mutual_information(nSubband, nTx, sInfo, aChannel, pNoise, rho)
% Function:
%   - calculate the maximum achievable mutual information
%   - decomposite the posynomials that contribute to mutual information
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
%   - gn: monomial components of posynomials that contribute to mutual 
%   information
%   - nTermGn: number of terms in the posynomial iMutual (Kn)
%
% Comments:
%   - there is always a constant term (i.e. 1) in each posynomials
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms in the result posynomial (Kn)
nTermGn = 1 + nTx ^ 2;

cvx_begin gp
variable gn(nSubband, nTermGn)
% constant term 1
gn(:, 1) = 1;

for n = 1: nSubband
%     c = 0; 
    iTerm = 1;
    for m0 = 1: nTx
        for m1 = 1: nTx
            iTerm = iTerm + 1;
            gn(n, iTerm) = (1 - rho) / pNoise * (sInfo(n, m0) * aChannel(n, m0)) * (sInfo(n, m1) * aChannel(n, m1));
%             c = c + (sInfo(n, m0) * aChannel(n, m0)) * (sInfo(n, m1) * aChannel(n, m1));
        end
    end
%     iMutual = iMutual + log(1 + (1 - rho) / pNoise * c);
end
iMutual = log(prod(sum(gn, 2))) / log(2);
end

