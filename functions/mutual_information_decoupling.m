function [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information_decoupling(Transceiver, Channel, Solution)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - Transceiver.noisePower: noise power
%   - Channel.subband: number of subbands (subcarriers)
%   - Channel.subbandAmplitude: amplitude of channel impulse response
%   - Solution.infoAmplitude: optimum amplitude assigned to information waveform
%   - Solution.infoSplitRatio: information splitting ratio
%
% OutputArg(s):
%   - mutualInfo: maximum achievable mutual information
%   - monomialOfMutualInfo: monomial components of posynomials that contribute to mutual information
%   - exponentOfMutualInfo: exponent of the mutual information in the geometric mean
%
% Comments:
%   - returns per-subband rate that decreases as the number of subbands increases
%   - decouple the design of the spatial and frequency domain weights
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


v2struct(Transceiver, {'fieldNames', 'noisePower'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude'});
v2struct(Solution, {'fieldNames', 'infoSplitRatio', 'infoAmplitude'});

% number of terms (Kn) in the result posynomials (a constant and a monomial)
nTerms = 2;

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
    monomialOfMutualInfo(iSubband, 2) = infoSplitRatio / noisePower * (infoAmplitude(iSubband) ^ 2 * norm(subbandAmplitude(iSubband, :)) ^ 2);
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

