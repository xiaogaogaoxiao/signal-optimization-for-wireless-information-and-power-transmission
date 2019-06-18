function [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio)
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
%   - infoSplitRatio: information splitting ratio
%
% OutputArg(s):
%   - mutualInfo: maximum achievable mutual information
%   - monomialOfMutualInfo: monomial components of posynomials that contribute to mutual information
%   - exponentOfMutualInfo: exponent of the mutual information in the geometric mean
%
% Comments:
%   - a general approach
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms (Kn) in the result posynomials
nTerms = 1 + nTxs ^ 2;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize (a constant term 1 exists in each posynomial)
if isKnown
    % placeholder for actual values (doubles)
    monomialOfMutualInfo = ones(nSubbands, nTerms);
else
    % placeholder for CVX variables (expressions)
    monomialOfMutualInfo = cvx(ones(nSubbands, nTerms));
end

for iSubband = 1: nSubbands
    iTerm = 1;
    for iTx0 = 1: nTxs
        for iTx1 = 1: nTxs
            iTerm = iTerm + 1;
            monomialOfMutualInfo(iSubband, iTerm) = infoSplitRatio / noisePower * ...
                (infoAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0)) * ...
                (infoAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1));
        end
    end
end

if isKnown
    posynomialOfMutualInfo = sum(monomialOfMutualInfo, 2);
    exponentOfMutualInfo = monomialOfMutualInfo ./ repmat(posynomialOfMutualInfo, [1 nTerms]);
    mutualInfo = log(prod(posynomialOfMutualInfo)) / log(2);
else
    exponentOfMutualInfo = NaN;
    mutualInfo = NaN;
end

end

