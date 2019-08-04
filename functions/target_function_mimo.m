function [targetFun, negativePosynomial, positiveMonomial, positiveExponent] = target_function_mimo(k2, k4, tx, rx, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerPhase, infoPhase, powerSplitRatio)
% Function:
%   - formulate the target (output current) as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decompose target posynomial as sum of monomials
%
% InputArg(s):
%   - k2: diode k-parameter
%   - k4: diode k-parameter
%   - tx: number of transmit antennas
%   - rx: number of receive antennas
%   - resistance: antenna resistance
%   - subbandAmplitude: amplitude of channel impulse response
%   - subband: number of subbands (subcarriers)
%   - powerAmplitude: optimum amplitude assigned to power waveform
%   - infoAmplitude: optimum amplitude assigned to information waveform
%   - powerPhase: phase of power waveform
%   - infoPhase: phase of information waveform
%   - powerSplitRatio: power splitting ratio
%
% OutputArg(s):
%   - targetFun: target posynomial (zDc) that proportional to the output current
%   - negativePosynomial: negative posynomial (f2) of the target signomial
%   - positiveMonomial: positive monomial (terms of f1) of the target signomial
%   - positiveExponent: exponent of the positive posynomial in the geometric mean
%
% Comments:
%   - for MIMO
%   - only consider the most fundamental nonlinear model (i.e. truncate at the fourth order)
%
% Author & Date: Yang (i@snowztail.com) - 03 Aug 19


% number of terms in each expression
nTermsP2 = subband * tx ^ 2 * rx;
nTermsP4 = subband * (2 * subband ^ 2 + 1) / 3 * tx ^ 4 * rx;
nTermsI2 = subband * tx ^ 2 * rx;
nTermsI4 = (subband * tx ^ 2) ^ 2 * rx;
nTermsP2I2 = (subband * tx ^ 2) ^ 2 * rx;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize
if isKnown
    % placeholder for actual values (doubles)
    monomialOfTargetP2 = zeros(1, nTermsP2);
    monomialOfTargetP4 = zeros(1, nTermsP4);
    monomialOfTargetI2 = zeros(1, nTermsI2);
    monomialOfTargetI4 = zeros(1, nTermsI4);
    monomialOfTargetP2I2 = zeros(1, nTermsP2I2);
else
    % placeholder for CVX variables (expressions)
    monomialOfTargetP2 = cvx(zeros(1, nTermsP2));
    monomialOfTargetP4 = cvx(zeros(1, nTermsP4));
    monomialOfTargetI2 = cvx(zeros(1, nTermsI2));
    monomialOfTargetI4 = cvx(zeros(1, nTermsI4));
    monomialOfTargetP2I2 = cvx(zeros(1, nTermsP2I2));
end

% coefficients of signomial
coefP2 = zeros(1, nTermsP2);
coefP4 = zeros(1, nTermsP4);
coefI2 = zeros(1, nTermsI2);
coefI4 = zeros(1, nTermsI4);
coefP2I2 = zeros(1, nTermsP2I2);

% monomials related to the time-average of power (multisine) signal to the second order
iTermP2 = 0;
for iSubband = 1: subband
    for iTx0 = 1: tx
        for iTx1 = 1: tx
            for iRx = 1: rx
                iTermP2 = iTermP2 + 1;
                coefP2(iTermP2) = cos(powerPhase(iSubband, iTx0, iRx) - powerPhase(iSubband, iTx1, iRx));
                monomialOfTargetP2(iTermP2) = coefP2(iTermP2) * ...
                    (powerAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0, iRx)) * ...
                    (powerAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1, iRx));
            end
        end
    end
end
clearvars iSubband iTx0 iTx1;

% monomials related to the time-average of power (multisine) signal to the fourth order
iTermP4 = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        for iSubband2 = 1: subband
            iSubband3 = iSubband0 + iSubband1 - iSubband2;
            isValid = iSubband3 >= 1 && iSubband3 <= subband;
            if isValid
                for iTx0 = 1: tx
                    for iTx1 = 1: tx
                        for iTx2 = 1: tx
                            for iTx3 = 1: tx
                                for iRx = 1: rx
                                    iTermP4 = iTermP4 + 1;
                                    coefP4(iTermP4) = cos(powerPhase(iSubband0, iTx0, iRx) + powerPhase(iSubband1, iTx1, iRx) -...
                                        powerPhase(iSubband2, iTx2, iRx) - powerPhase(iSubband3, iTx3, iRx));
                                    monomialOfTargetP4(iTermP4) = coefP4(iTermP4) * ...
                                        (powerAmplitude(iSubband0, iTx0) * subbandAmplitude(iSubband0, iTx0, iRx)) * ...
                                        (powerAmplitude(iSubband1, iTx1) * subbandAmplitude(iSubband1, iTx1, iRx)) * ...
                                        (powerAmplitude(iSubband2, iTx2) * subbandAmplitude(iSubband2, iTx2, iRx)) * ...
                                        (powerAmplitude(iSubband3, iTx3) * subbandAmplitude(iSubband3, iTx3, iRx));
                                end
                            end
                        end
                    end
                end
            else
                continue;
            end
        end
    end
end
clearvars iSubband0 iSubband1 iSubband2 iSubband3 iTx0 iTx1 iTx2 iTx3;

% monomials related to the expectation of time-average of information (modulated) signal to the second order
iTermI2 = 0;
for iSubband = 1: subband
    for iTx0 = 1: tx
        for iTx1 = 1: tx
            for iRx = 1: rx
                iTermI2 = iTermI2 + 1;
                coefI2(iTermI2) = cos(infoPhase(iSubband, iTx0, iRx) - infoPhase(iSubband, iTx1, iRx));
                monomialOfTargetI2(iTermI2) = coefI2(iTermI2) * ...
                    (infoAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0, iRx)) * ...
                    (infoAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1, iRx));
            end
        end
    end
end
clearvars iSubband iTx0 iTx1;

% monomials related to the expectation of time-average of information (modulated) signal to the fourth order
iTermI4 = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        for iTx0 = 1: tx
            for iTx1 = 1: tx
                for iTx2 = 1: tx
                    for iTx3 = 1: tx
                        for iRx = 1: rx
                            iTermI4 = iTermI4 + 1;
                            coefI4(iTermI4) = cos(infoPhase(iSubband0, iTx0, iRx) + infoPhase(iSubband1, iTx1, iRx) -...
                                infoPhase(iSubband0, iTx2, iRx) - infoPhase(iSubband1, iTx3, iRx));
                            monomialOfTargetI4(iTermI4) = coefI4(iTermI4) * ...
                                (infoAmplitude(iSubband0, iTx0) * subbandAmplitude(iSubband0, iTx0, iRx)) * ...
                                (infoAmplitude(iSubband0, iTx2) * subbandAmplitude(iSubband0, iTx2, iRx)) * ...
                                (infoAmplitude(iSubband1, iTx1) * subbandAmplitude(iSubband1, iTx1, iRx)) * ...
                                (infoAmplitude(iSubband1, iTx3) * subbandAmplitude(iSubband1, iTx3, iRx));
                        end
                    end
                end
            end
        end
    end
end
clearvars iSubband0 iSubband1 iTx0 iTx1 iTx2 iTx3;

% monomials related to the combined power-info terms
iTermP2I2 = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        for iTx0 = 1: tx
            for iTx1 = 1: tx
                for iTx2 = 1: tx
                    for iTx3 = 1: tx
                        for iRx = 1: rx
                            iTermP2I2 = iTermP2I2 + 1;
                            coefP2I2(iTermP2I2) = cos(powerPhase(iSubband0, iTx0, iRx) - powerPhase(iSubband0, iTx2, iRx)) * ...
                                cos(infoPhase(iSubband1, iTx1, iRx) - infoPhase(iSubband1, iTx3, iRx));
                            monomialOfTargetP2I2(iTermP2I2) = coefP2I2(iTermP2I2) * ...
                                (powerAmplitude(iSubband0, iTx0) * subbandAmplitude(iSubband0, iTx0, iRx)) * ...
                                (powerAmplitude(iSubband0, iTx2) * subbandAmplitude(iSubband0, iTx2, iRx)) * ...
                                (infoAmplitude(iSubband1, iTx1) * subbandAmplitude(iSubband1, iTx1, iRx)) * ...
                                (infoAmplitude(iSubband1, iTx3) * subbandAmplitude(iSubband1, iTx3, iRx));
                        end
                    end
                end
            end
        end
    end
end
clearvars iSubband0 iSubband1 iTx0 iTx1 iTx2 iTx3;

monomialOfTargetP2 = monomialOfTargetP2 * 0.5 * k2 * powerSplitRatio * resistance;
monomialOfTargetP4 = monomialOfTargetP4 * 0.375 * k4 * powerSplitRatio ^ 2 * resistance ^ 2;
monomialOfTargetI2 = monomialOfTargetI2 * 0.5 * k2 * powerSplitRatio * resistance;
monomialOfTargetI4 = monomialOfTargetI4 * 0.75 * k4 * powerSplitRatio ^ 2 * resistance ^ 2;
monomialOfTargetP2I2 = monomialOfTargetP2I2 * 1.5 * k4 * powerSplitRatio ^ 2 * resistance ^ 2;

% group monomials and coefficients
monomialOfTarget = [monomialOfTargetP2 monomialOfTargetP4 monomialOfTargetI2 monomialOfTargetI4 monomialOfTargetP2I2];
coef = [coefP2 coefP4 coefI2 coefI4 coefP2I2];

positiveMonomial = monomialOfTarget(coef > 0);
negativeMonomial = - monomialOfTarget(coef < 0);

negativePosynomial = sum(negativeMonomial);

if isKnown
    positivePosynomial = sum(positiveMonomial);
    positiveExponent = positiveMonomial / positivePosynomial;
    targetFun = positivePosynomial - negativePosynomial;
else
    positiveExponent = NaN;
    targetFun = NaN;
end

end
