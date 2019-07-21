function [mutualInfo, monomialOfMutualInfo, posynomialOfPowerTerms, exponentOfMutualInfo] = mutual_information_lower_bound(tx, noisePower, subband, subbandAmplitude, powerAmplitude, infoAmplitude, infoSplitRatio)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - tx: number of transmit antennas
%   - noisePower: noise power
%   - subband: number of subbands (subcarriers)
%   - subbandAmplitude: amplitude of channel impulse response
%   - powerAmplitude: optimum amplitude assigned to power waveform
%   - infoAmplitude: optimum amplitude assigned to information waveform
%   - infoSplitRatio: information splitting ratio
%
% OutputArg(s):
%   - mutualInfo: maximum achievable mutual information
%   - monomialOfMutualInfo: monomial components of posynomials that contribute to mutual information
%   - posynomialOfPowerTerms: power posynomials that contribute to mutual information as interference
%   - exponentOfMutualInfo: exponent of the mutual information in the geometric mean
%
% Comments:
%   - returns per-subband rate that decreases as the number of subbands increases
%   - assume the power waveform is CSCG that creates an interference and rate loss
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms in the power and information posynomials
nSubTerms = tx ^ 2;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize
if isKnown
    % placeholder for actual values (doubles)
    monomialOfPowerTerms = zeros(subband, nSubTerms);
    monomialOfInfoTerms = zeros(subband, nSubTerms);
else
    % placeholder for CVX variables (expressions)
    monomialOfPowerTerms = cvx(zeros(subband, nSubTerms));
    monomialOfInfoTerms = cvx(zeros(subband, nSubTerms));
end

for iSubband = 1: subband
    iSubTerm = 0;
    for iTx0 = 1: tx
        for iTx1 = 1: tx
            iSubTerm = iSubTerm + 1;
            monomialOfPowerTerms(iSubband, iSubTerm) = ...
                (powerAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0)) * ...
                (powerAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1));
            monomialOfInfoTerms(iSubband, iSubTerm) = ...
                (infoAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0)) * ...
                (infoAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1));
        end
    end
end

monomialOfMutualInfo = [ones(subband, 1), infoSplitRatio / noisePower * monomialOfPowerTerms, infoSplitRatio / noisePower * monomialOfInfoTerms];

% number of terms (Jn) in the result posynomials
nTerms = size(monomialOfMutualInfo, 2);

% components inside log are based on posynomials
posynomialOfPowerTerms = sum(monomialOfPowerTerms, 2);
posynomialOfInfoTerms = sum(monomialOfInfoTerms, 2);
posynomialOfMutualInfo = sum(monomialOfMutualInfo, 2);

% exponents of geometric means
exponentOfMutualInfo = monomialOfMutualInfo ./ repmat(posynomialOfMutualInfo, [1 nTerms]);

if isKnown
    % numerical solutions
    mutualInfo = log(prod(1 + infoSplitRatio * posynomialOfInfoTerms ./ (noisePower + infoSplitRatio * posynomialOfPowerTerms))) / log(2);
else
    % the expression is neither supported by CVX nor to be used by the algorithm
    mutualInfo = NaN;
end
% per-subband rate
mutualInfo = mutualInfo / subband;

end
