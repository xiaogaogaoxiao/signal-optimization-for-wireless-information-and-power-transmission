function [targetFun, monomialOfTarget, exponentOfTarget] = target_function_decoupling(k2, k4, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerSplitRatio)
% Function:
%   - formulate the target proportional to the output current as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decomposite target posynomial as sum of monomials
%
% InputArg(s):
%   - k2: diode k-parameter
%   - k4: diode k-parameter
%   - resistance: antenna resistance
%   - subbandAmplitude: amplitude of channel impulse response
%   - subband: number of subbands (subcarriers)
%   - powerAmplitude: optimum amplitude assigned to power waveform
%   - infoAmplitude: optimum amplitude assigned to information waveform
%   - powerSplitRatio: power splitting ratio
%
% OutputArg(s):
%   - targetFun: target posynomial (zDc) that proportional to the output current
%   - monomialOfTarget: monomials (g) as components of the target posynomial
%   - exponentOfTarget: exponent of the target function in the geometric mean
%
% Comments:
%   - decouple the design of the spatial and frequency domain weights
%   - only consider the most fundamental nonlinear model (i.e. truncate at the fourth order)
%   - for the single-user case, the optimum phases of power and information waveforms equal the negative phase of channel impulse response
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms in each expression
nTermsP2 = subband;
nTermsP4 = subband * (2 * subband ^ 2 + 1) / 3;
nTermsI2 = subband;
nTermsI4 = subband ^ 2;
nTermsP2I2 = subband ^ 2;

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
    iTermP2 = iTermP2 + 1;
    monomialOfTargetP2(iTermP2) = norm(subbandAmplitude(iSubband, :)) ^ 2 * powerAmplitude(iSubband) ^ 2;
end
clearvars iSubband;

% monomials related to the time-average of power (multisine) signal to the fourth order
iTermP4 = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        for iSubband2 = 1: subband
            iSubband3 = iSubband0 + iSubband1 - iSubband2;
            isValid = iSubband3 >= 1 && iSubband3 <= subband;
            if isValid
                iTermP4 = iTermP4 + 1;
                monomialOfTargetP4(iTermP4) = ...
                    (powerAmplitude(iSubband0) * norm(subbandAmplitude(iSubband0, :))) * ...
                    (powerAmplitude(iSubband1) * norm(subbandAmplitude(iSubband1, :))) * ...
                    (powerAmplitude(iSubband2) * norm(subbandAmplitude(iSubband2, :))) * ...
                    (powerAmplitude(iSubband3) * norm(subbandAmplitude(iSubband3, :)));
            else
                continue;
            end
        end
    end
end
clearvars iSubband0 iSubband1 iSubband2 iSubband3;

% monomials related to the expectation of time-average of information (modulated) signal to the second order
iTermI2 = 0;
for iSubband = 1: subband
    iTermI2 = iTermI2 + 1;
    monomialOfTargetI2(iTermI2) = norm(subbandAmplitude(iSubband, :)) ^ 2 * infoAmplitude(iSubband) ^ 2;
end
clearvars iSubband;

% monomials related to the expectation of time-average of information (modulated) signal to the fourth order
iTermI4 = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        iTermI4 = iTermI4 + 1;
        monomialOfTargetI4(iTermI4) = ...
            (infoAmplitude(iSubband0) ^ 2 * norm(subbandAmplitude(iSubband0, :)) ^ 2) * ...
            (infoAmplitude(iSubband1) ^ 2 * norm(subbandAmplitude(iSubband1, :)) ^ 2);
    end
end
clearvars iSubband0 iSubband1;

% monomials related to the combined power-info terms
iTermP2I2 = 0;
for iSubband0 = 1: subband
    for iSubband1 = 1: subband
        iTermP2I2 = iTermP2I2 + 1;
        monomialOfTargetP2I2(iTermP2I2) = ...
            (norm(subbandAmplitude(iSubband0, :)) ^ 2 * powerAmplitude(iSubband0) ^ 2) * ...
            (norm(subbandAmplitude(iSubband1, :)) ^ 2 * infoAmplitude(iSubband1) ^ 2);
    end
end
clearvars iSubband0 iSubband1;

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

