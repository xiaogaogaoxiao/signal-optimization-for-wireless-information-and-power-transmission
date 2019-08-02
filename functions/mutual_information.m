function [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information(tx, noisePower, subband, subbandAmplitude, infoAmplitude, infoPhase, infoSplitRatio)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - tx: number of transmit antennas
%   - noisePower: noise power
%   - subband: number of subbands (subcarriers)
%   - subbandAmplitude: amplitude of channel impulse response
%   - infoAmplitude: optimum amplitude assigned to information waveform
%   - infoPhase: phase of information waveform
%   - infoSplitRatio: information splitting ratio
%
% OutputArg(s):
%   - mutualInfo: maximum achievable mutual information
%   - monomialOfMutualInfo: monomial components of posynomials that contribute to mutual information
%   - exponentOfMutualInfo: exponent of the mutual information in the geometric mean
%
% Comments:
%   - returns per-subband rate that decreases as the number of subbands increases
%   - a general approach
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 01 Aug 19


% number of terms (Kn) in the result posynomials
nTerms = 1 + tx ^ 2;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize (a constant term 1 exists in each posynomial)
if isKnown
    % placeholder for actual values (doubles)
    monomialOfMutualInfo = ones(subband, nTerms);
else
    % placeholder for CVX variables (expressions)
    monomialOfMutualInfo = cvx(ones(subband, nTerms));
end

for iSubband = 1: subband
    iTerm = 1;
    for iTx0 = 1: tx
        for iTx1 = 1: tx
            iTerm = iTerm + 1;
            monomialOfMutualInfo(iSubband, iTerm) = infoSplitRatio / noisePower * ...
                (infoAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0)) * ...
                (infoAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1)) * ...
                cos(infoPhase(iSubband, iTx0) - infoPhase(iSubband, iTx1));
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
% per-subband rate
mutualInfo = mutualInfo / subband;

end
