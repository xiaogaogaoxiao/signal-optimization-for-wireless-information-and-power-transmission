function [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information_decoupling(nSubbands, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
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
%   - decouple the design of the spatial and frequency domain weights
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms (Kn) in the result posynomials (a constant and a monomial)
nTerms = 2;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize
if isKnown
    % placeholder for actual values (doubles)
    monomialOfMutualInfo = zeros(nSubbands, nTerms);
else
    % placeholder for CVX variables (expressions)
    monomialOfMutualInfo = cvx(zeros(nSubbands, nTerms));
end

% a constant term 1 exists in each posynomial
monomialOfMutualInfo(:, 1) = 1;

for iSubband = 1: nSubbands
    monomialOfMutualInfo(iSubband, 2) = infoSplitRatio / noisePower * (infoAmplitude(iSubband) ^ 2 * norm(channelAmplitude(iSubband, :)) ^ 2);
end

% components inside log are posynomials
posynomialOfMutualInfo = sum(monomialOfMutualInfo, 2);

% exponents of geometric means
exponentOfMutualInfo = monomialOfMutualInfo ./ repmat(posynomialOfMutualInfo, [1 nTerms]);

% mutual information
mutualInfo = log(prod(posynomialOfMutualInfo)) / log(2);

end

