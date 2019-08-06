function [targetFun, monomialOfTarget, exponentOfTarget] = target_function_no_power_waveform(k2, k4, resistance, subbandAmplitude, subband, infoAmplitude, powerSplitRatio)
% Function:
%   - formulate the target (output current) as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decompose target posynomial as sum of monomials
%
% InputArg(s):
%   - k2: diode k-parameter
%   - k4: diode k-parameter
%   - resistance: antenna resistance
%   - subbandAmplitude: amplitude of channel impulse response
%   - subband: number of subbands (subcarriers)
%   - infoAmplitude: optimum amplitude assigned to information waveform
%   - powerSplitRatio: power splitting ratio
%
% OutputArg(s):
%   - targetFun: target posynomial (zDc) that proportional to the output current
%   - monomialOfTarget: monomials (g) as components of the target posynomial
%   - exponentOfTarget: exponent of the target function in the geometric mean
%
% Comments:
%   - contribution by information waveform only
%   - decouple the design of the spatial and frequency domain weights
%   - only consider the most fundamental nonlinear model (i.e. truncate at the fourth order)
%   - for the single-user case, the optimum phases equal the negative phase of channel impulse response
%
% Author & Date: Yang (i@snowztail.com) - 05 Aug 19


% number of terms in each expression
nTermsI2 = subband;
nTermsI4 = subband ^ 2;

% type of variables
isKnown = isa(infoAmplitude, 'double');

% initialize
if isKnown
    % placeholder for actual values (doubles)
    monomialOfTargetI2 = zeros(1, nTermsI2);
    monomialOfTargetI4 = zeros(1, nTermsI4);
else
    % placeholder for CVX variables (expressions)
    monomialOfTargetI2 = cvx(zeros(1, nTermsI2));
    monomialOfTargetI4 = cvx(zeros(1, nTermsI4));
end

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

monomialOfTargetI2 = monomialOfTargetI2 * 0.5 * k2 * powerSplitRatio * resistance;
monomialOfTargetI4 = monomialOfTargetI4 * 0.75 * k4 * powerSplitRatio ^ 2 * resistance ^ 2;

% group monomials
monomialOfTarget = [monomialOfTargetI2 monomialOfTargetI4];

if isKnown
    targetFun = sum(monomialOfTarget);
    exponentOfTarget = monomialOfTarget / targetFun;
else
    targetFun = NaN;
    exponentOfTarget = NaN;
end

end

