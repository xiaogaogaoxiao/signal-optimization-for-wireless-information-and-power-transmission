function [positivePosynomial, negativeMonomial, negativeExponent] = signomial(subband, powerAmplitude, subbandPhase, sampleFrequency, sampleTime, txPower, papr)
% Function:
%   - decompose average power signomial as sum of positive and negative monomials
%
% InputArg(s):
%   - subband: number of subbands (subcarriers)
%   - powerAmplitude: optimum amplitude assigned to power waveform
%   - subbandPhase: multipath channel phase on the subbands
%   - sampleFrequency: sampling frequency
%   - sampleTime: time point of oversampling
%   - txPower: average transmit power
%   - papr: peak-to-average power ratio
%
% OutputArg(s):
%   - positivePosynomial: sum of signomial's positive monomials
%   - negativeMonomial: negative monomials of signomial and PAPR-power term
%   - negativeExponent: exponent of the negative posynomial in the geometric mean
%
% Comments:
%   - the peak power corresponds to multisine while the average power is for the superposed waveform
%   - optimum for SISO
%
% Author & Date: Yang (i@snowztail.com) - 29 Jul 19

nTerms = subband ^ 2;

% type of variables
isKnown = isa(powerAmplitude, 'double');

% initialize
if isKnown
    % placeholder for actual values (doubles)
    monomialOfSignomial = zeros(1, nTerms);
else
    % placeholder for CVX variables (expressions)
    monomialOfSignomial = cvx(zeros(1, nTerms));
end
% product of cosine terms as coeffcients
coef = zeros(1, nTerms);

% signomial related to the average signal power
iTerm = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        iTerm = iTerm + 1;
        coef(iTerm) = cos(2 * pi * sampleFrequency(iSubband0) * sampleTime - subbandPhase(iSubband0)) .* ...
            cos(2 * pi * sampleFrequency(iSubband1) * sampleTime - subbandPhase(iSubband1));
        monomialOfSignomial(iTerm) = powerAmplitude(iSubband0) * powerAmplitude(iSubband1) * coef(iTerm);
    end
end
positiveMonomial = monomialOfSignomial(coef > 0);
negativeMonomial = - monomialOfSignomial(coef < 0);

% denominator as a sum of monomials
% negativeMonomial = [0.5 * papr * norm(powerAmplitude) ^ 2, negativeMonomial];
negativeMonomial = [papr * txPower, negativeMonomial];

if isKnown
    positivePosynomial = NaN;
    negativePosynomial = sum(negativeMonomial);
    negativeExponent = negativeMonomial / negativePosynomial;
else
    positivePosynomial = sum(positiveMonomial);
    negativeExponent = NaN;
end

end

