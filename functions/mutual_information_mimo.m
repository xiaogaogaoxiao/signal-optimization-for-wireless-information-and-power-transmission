function [mutualInfo, negativePosynomial, positiveMonomial, positiveExponent] = mutual_information_mimo(tx, rx, noisePower, subband, subbandAmplitude, infoAmplitude, infoPhase, infoSplitRatio)
% Function:
%   - formulate the maximum achievable mutual information with the provided parameters
%   - decomposite the posynomials that contribute to mutual information as sum of monomials
%
% InputArg(s):
%   - tx: number of transmit antennas
%   - rx: number of receive antennas
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
%   - for MIMO
%   - returns per-subband rate that decreases as the number of subbands increases
%   - there is a constant term (i.e. 1) in each posynomial
%
% Author & Date: Yang (i@snowztail.com) - 03 Aug 19


% number of terms (Kn) in the result posynomials
nTerms = 1 + tx ^ 2 * rx;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize (a constant term 1 exists in each posynomial)
coefOfMonomial = ones(subband, nTerms);
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
            for iRx = 1: rx
                iTerm = iTerm + 1;
                coefOfMonomial(iSubband, iTerm) = cos(infoPhase(iSubband, iTx0) - infoPhase(iSubband, iTx1));
                monomialOfMutualInfo(iSubband, iTerm) = abs(coefOfMonomial(iSubband, iTerm)) * infoSplitRatio / noisePower * ...
                    (infoAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0, iRx)) * ...
                    (infoAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1, iRx));
            end
        end
    end
end
clearvars iSubband iTx0 iTx1 iRx iTerm;

% unwrap product of signomials
unwrappedMonomial = monomialOfMutualInfo(1, :);
coef = coefOfMonomial(1, :);
for iSubband = 1: subband - 1
    [unwrappedMonomial] = unwrap_signomial(unwrappedMonomial, monomialOfMutualInfo(iSubband + 1, :));
    [coef] = unwrap_signomial(coef, coefOfMonomial(iSubband + 1, :));
end

positiveMonomial = unwrappedMonomial(coef > 0);
negativeMonomial = unwrappedMonomial(coef < 0);

negativePosynomial = sum(negativeMonomial);

if isKnown
    positivePosynomial = sum(positiveMonomial);
    positiveExponent = positiveMonomial / positivePosynomial;
    mutualInfo = log(positivePosynomial - negativePosynomial) / log(2);
else
    positiveExponent = NaN;
    mutualInfo = NaN;
end

% per-subband rate
mutualInfo = mutualInfo / subband;

end
