function [mutualInfo, monomialOfMutualInfo, posynomialOfPowerTerms, exponentOfMutualInfo] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - powerAmplitude: optimum amplitude assigned to power waveform [CVX variable]
%   - infoAmplitude: optimum amplitude assigned to information waveform [CVX variable]
%   - channelAmplitude: amplitude of channel impulse response
%   - noisePower: noise power
%   - infoSplitRatio: information splitting ratio
%
% OutputArg(s):
%   - mutualInfo: maximum achievable mutual information
%   - monomialOfMutualInfo: monomial components of posynomials that contribute to mutual information
%   - posynomialOfPowerTerms: power posynomials that contribute to mutual information as interference
%   - exponentOfMutualInfo: exponent of the mutual information in the geometric mean
%
% Comments:
%   - assume the power waveform is CSCG that creates an interference and rate loss
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms in the power and information posynomials
nSubTerms = nTxs ^ 2;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize
if isKnown
    % placeholder for actual values (doubles)
    monomialOfPowerTerms = zeros(nSubbands, nSubTerms);
    monomialOfInfoTerms = zeros(nSubbands, nSubTerms);
else
    % placeholder for CVX variables (expressions)
    monomialOfPowerTerms = cvx(zeros(nSubbands, nSubTerms));
    monomialOfInfoTerms = cvx(zeros(nSubbands, nSubTerms));
end

for iSubband = 1: nSubbands
    iTerm = 0;
    for iTx0 = 1: nTxs
        for iTx1 = 1: nTxs
            iTerm = iTerm + 1;
            monomialOfPowerTerms(iSubband, iTerm) = (powerAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0)) * (powerAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1));
            monomialOfInfoTerms(iSubband, iTerm) = (infoAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0)) * (infoAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1));
        end
    end
end

monomialOfMutualInfo = [ones(nSubbands, 1), infoSplitRatio / noisePower * monomialOfPowerTerms, infoSplitRatio / noisePower * monomialOfInfoTerms];

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

end

