function [targetFun, monomialOfTarget, exponentOfTarget] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance)
% Function:
%   - formulate the target proportional to the output current as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decomposite target posynomial as sum of monomials
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - powerAmplitude: optimum amplitude assigned to power waveform [CVX variable]
%   - infoAmplitude: optimum amplitude assigned to information waveform [CVX variable]
%   - channelAmplitude: amplitude of channel impulse response
%   - k2, k4: diode k-parameters
%   - powerSplitRatio: power splitting ratio
%   - resistance: antenna resistance
%
% OutputArg(s):
%   - target: target posynomial (zDc) that proportional to the output current
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
nTermsP2 = nSubbands;
nTermsP4 = nSubbands * (2 * nSubbands ^ 2 + 1) / 3;
nTermsI2 = nSubbands;
nTermsI4 = nSubbands ^ 2;
nTermsP2I2 = nSubbands ^ 2;

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
for iSubband = 1: nSubbands
    iTermP2 = iTermP2 + 1;
    monomialOfTargetP2(iTermP2) = 0.5 * k2 * powerSplitRatio * resistance * norm(channelAmplitude(iSubband, :)) ^ 2 * powerAmplitude(iSubband) ^ 2;
end
clearvars iSubband;

% monomials related to the time-average of power (multisine) signal to the fourth order
iTermP4 = 0;
for iSubband0 = 1: nSubbands
    for iSubband1 = 1: nSubbands
        for iSubband2 = 1: nSubbands
            iSubband3 = iSubband0 + iSubband1 - iSubband2;
            if iSubband3 < 1 || iSubband3 > nSubbands
                continue;
            else
                iTermP4 = iTermP4 + 1;
                monomialOfTargetP4(iTermP4) = 0.375 * k4 * powerSplitRatio ^ 2 * resistance ^ 2 * (powerAmplitude(iSubband0) * norm(channelAmplitude(iSubband0, :))) * (powerAmplitude(iSubband1) * norm(channelAmplitude(iSubband1, :))) * (powerAmplitude(iSubband2) * norm(channelAmplitude(iSubband2, :))) * (powerAmplitude(iSubband3) * norm(channelAmplitude(iSubband3, :)));
            end
        end
    end
end
clearvars iSubband0 iSubband1 iSubband2 iSubband3;

% monomials related to the expectation of time-average of information (modulated) signal to the second order
iTermI2 = 0;
for iSubband = 1: nSubbands
    iTermI2 = iTermI2 + 1;
    monomialOfTargetI2(iTermI2) = 0.5 * k2 * powerSplitRatio * resistance * norm(channelAmplitude(iSubband, :)) ^ 2 * infoAmplitude(iSubband) ^ 2;
end
clearvars iSubband;

% monomials related to the expectation of time-average of information (modulated) signal to the fourth order
iTermI4 = 0;
for iSubband0 = 1: nSubbands
    for iSubband1 = 1: nSubbands
        iTermI4 = iTermI4 + 1;
        monomialOfTargetI4(iTermI4) = 0.75 * k4 * powerSplitRatio ^ 2 * resistance ^ 2 * (infoAmplitude(iSubband0) ^ 2 * norm(channelAmplitude(iSubband0, :)) ^ 2) * (infoAmplitude(iSubband1) ^ 2 * norm(channelAmplitude(iSubband1, :)) ^ 2);
    end
end
clearvars iSubband0 iSubband1;

% monomials related to the combined power-info terms
iTermP2I2 = 0;
for iTermP2 = 1: nTermsP2
    for iTermI2 = 1: nTermsI2
        iTermP2I2 = iTermP2I2 + 1;
        monomialOfTargetP2I2(iTermP2I2) = 6 * k4 / k2 ^ 2 * monomialOfTargetP2(iTermP2) * monomialOfTargetI2(iTermI2);
    end
end

% group monomials
monomialOfTarget = [monomialOfTargetP2 monomialOfTargetP4 monomialOfTargetI2 monomialOfTargetI4 monomialOfTargetP2I2];

% sum monomials to obtain target posynomial
targetFun = sum(monomialOfTarget);

% exponents of geometric means
exponentOfTarget = monomialOfTarget / targetFun;

end

