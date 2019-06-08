function [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, splitRatio)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - infoAmplitude: optimum amplitude assigned to information waveform [CVX variable]
%   - channelAmplitude: amplitude of channel impulse response
%   - noisePower: noise power
%   - splitRatio: power splitting ratio
%
% OutputArg(s):
%   - mutualInfo: maximum achievable mutual information
%   - monomialOfMutualInfo: monomial components of posynomials that contribute to mutual information
%   - exponentOfMutualInfo: exponent of the mutual information in the geometric mean
%
% Comments:
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms (Kn) in the result posynomials
nTerms = 1 + nTxs ^ 2;

cvx_begin gp

    variable monomialOfMutualInfo(nSubbands, nTerms)

    % a constant term 1 exists in each posynomial
    monomialOfMutualInfo(:, 1) = 1;

    for iSubband = 1: nSubbands
        iTerm = 1;
        for iTx0 = 1: nTxs
            for iTx1 = 1: nTxs
                iTerm = iTerm + 1;
                monomialOfMutualInfo(iSubband, iTerm) = (1 - splitRatio) / noisePower * (infoAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0)) * (infoAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1));
            end
        end
    end
    posynomialOfMutualInfo = sum(monomialOfMutualInfo, 2);
    exponentOfMutualInfo = monomialOfMutualInfo ./ repmat(posynomialOfMutualInfo, [1, nTerms]);
    
    mutualInfo = log(prod(posynomialOfMutualInfo)) / log(2);
    
cvx_end

end

