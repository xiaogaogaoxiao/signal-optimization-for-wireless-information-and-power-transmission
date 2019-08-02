function [targetFun, monomialOfTarget, exponentOfTarget] = target_function(k2, k4, tx, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerPhase, infoPhase, powerSplitRatio)
% Function:
%   - formulate the target (output current) as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decompose target posynomial as sum of monomials
%
% InputArg(s):
%   - k2: diode k-parameter
%   - k4: diode k-parameter
%   - tx: number of transmit antennas
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
%   - monomialOfTarget: monomials (g) as components of the target posynomial
%   - exponentOfTarget: exponent of the target function in the geometric mean
%
% Comments:
%   - a general approach
%   - only consider the most fundamental nonlinear model (i.e. truncate at the fourth order)
%
% Author & Date: Yang (i@snowztail.com) - 01 Aug 19


% number of terms in each expression
nTermsP2 = subband * tx ^ 2;
nTermsP4 = subband * (2 * subband ^ 2 + 1) / 3 * tx ^ 4;
nTermsI2 = subband * tx ^ 2;
nTermsI4 = (subband * tx ^ 2) ^ 2;
nTermsP2I2 = (subband * tx ^ 2) ^ 2;

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

% monomials related to the time-average of power (multisine) signal to the second order
iTermP2 = 0;
for iSubband = 1: subband
    for iTx0 = 1: tx
        for iTx1 = 1: tx
            iTermP2 = iTermP2 + 1;
            monomialOfTargetP2(iTermP2) = ...
                (powerAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0)) * ...
                (powerAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1)) * ...
                cos(powerPhase(iSubband, iTx0) - powerPhase(iSubband, iTx1));
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
                                iTermP4 = iTermP4 + 1;
                                monomialOfTargetP4(iTermP4) = ...
                                    (powerAmplitude(iSubband0, iTx0) * subbandAmplitude(iSubband0, iTx0)) * ...
                                    (powerAmplitude(iSubband1, iTx1) * subbandAmplitude(iSubband1, iTx1)) * ...
                                    (powerAmplitude(iSubband2, iTx2) * subbandAmplitude(iSubband2, iTx2)) * ...
                                    (powerAmplitude(iSubband3, iTx3) * subbandAmplitude(iSubband3, iTx3)) * ...
                                    cos(powerPhase(iSubband0, iTx0) + powerPhase(iSubband1, iTx1) - powerPhase(iSubband2, iTx2) - powerPhase(iSubband3, iTx3));
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
            iTermI2 = iTermI2 + 1;
            monomialOfTargetI2(iTermI2) = ...
                (infoAmplitude(iSubband, iTx0) * subbandAmplitude(iSubband, iTx0)) * ...
                (infoAmplitude(iSubband, iTx1) * subbandAmplitude(iSubband, iTx1)) * ...
                cos(infoPhase(iSubband, iTx0) - infoPhase(iSubband, iTx1));
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
                        iTermI4 = iTermI4 + 1;
                        monomialOfTargetI4(iTermI4) = ...
                            (infoAmplitude(iSubband0, iTx0) * subbandAmplitude(iSubband0, iTx0)) * ...
                            (infoAmplitude(iSubband0, iTx2) * subbandAmplitude(iSubband0, iTx2)) * ...
                            (infoAmplitude(iSubband1, iTx1) * subbandAmplitude(iSubband1, iTx1)) * ...
                            (infoAmplitude(iSubband1, iTx3) * subbandAmplitude(iSubband1, iTx3)) * ...
                            cos(infoPhase(iSubband0, iTx0) + infoPhase(iSubband1, iTx1) - infoPhase(iSubband0, iTx2) - infoPhase(iSubband1, iTx3));
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
                        iTermP2I2 = iTermP2I2 + 1;
                        monomialOfTargetP2I2(iTermP2I2) = ...
                            (powerAmplitude(iSubband0, iTx0) * subbandAmplitude(iSubband0, iTx0)) * ...
                            (powerAmplitude(iSubband0, iTx2) * subbandAmplitude(iSubband0, iTx2)) * ...
                            cos(powerPhase(iSubband0, iTx0) - powerPhase(iSubband0, iTx2)) * ...
                            (infoAmplitude(iSubband1, iTx1) * subbandAmplitude(iSubband1, iTx1)) * ...
                            (infoAmplitude(iSubband1, iTx3) * subbandAmplitude(iSubband1, iTx3)) * ...
                            cos(infoPhase(iSubband1, iTx1) - infoPhase(iSubband1, iTx3));
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

% group monomials
monomialOfTarget = [monomialOfTargetP2 monomialOfTargetP4 monomialOfTargetI2 monomialOfTargetI4 monomialOfTargetP2I2];

if isKnown
    targetFun = sum(monomialOfTarget);
    exponentOfTarget = monomialOfTarget / targetFun;
else
    targetFun = NaN;
    exponentOfTarget = NaN;
end

end
