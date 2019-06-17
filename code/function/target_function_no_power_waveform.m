function [targetFun, monomialOfTarget, exponentOfTarget] = target_function_no_power_waveform(nSubbands, nTxs, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance)
% Function:
%   - formulate the target proportional to the output current as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decomposite target posynomial as sum of monomials
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - infoAmplitude: optimum amplitude assigned to information waveform [CVX variable]
%   - channelAmplitude: amplitude of channel impulse response
%   - k2, k4: diode k-parameters
%   - powerSplitRatio: power splitting ratio
%   - resistance: antenna resistance
%
% OutputArg(s):
%   - targetFun: target posynomial (zDc) that proportional to the output current
%   - monomialOfTarget: monomials (g) as components of the target posynomial
%   - exponentOfTarget: exponent of the target function in the geometric mean
%
% Comments:
%   - no power waveform
%   - only consider the most fundamental nonlinear model (i.e. truncate at the fourth order)
%   - for the single-user case, the optimum phases of power and information waveforms equal the negative phase of channel impulse response
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19


% number of terms in each expression
nTermsI2 = nSubbands * nTxs ^ 2;
nTermsI4 = (nSubbands * nTxs ^ 2) ^ 2;

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
for iSubband = 1: nSubbands
    for iTx0 = 1: nTxs
        for iTx1 = 1: nTxs
            iTermI2 = iTermI2 + 1;
            monomialOfTargetI2(iTermI2) = ...
                (infoAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0)) * ...
                (infoAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1));
        end
    end
end
clearvars iSubband iTx0 iTx1;

% monomials related to the expectation of time-average of information (modulated) signal to the fourth order
iTermI4 = 0;
for iSubband0 = 1: nSubbands
    for iSubband1 = 1: nSubbands
        for iTx0 = 1: nTxs
            for iTx1 = 1: nTxs
                for iTx2 = 1: nTxs
                    for iTx3 = 1: nTxs
                        iTermI4 = iTermI4 + 1;
                        monomialOfTargetI4(iTermI4) = ...
                            (infoAmplitude(iSubband0, iTx0) * channelAmplitude(iSubband0, iTx0)) * ...
                            (infoAmplitude(iSubband0, iTx2) * channelAmplitude(iSubband0, iTx2)) * ...
                            (infoAmplitude(iSubband1, iTx1) * channelAmplitude(iSubband1, iTx1)) * ...
                            (infoAmplitude(iSubband1, iTx3) * channelAmplitude(iSubband1, iTx3));
                    end
                end
            end
        end
    end
end
clearvars iSubband0 iSubband1 iTx0 iTx1 iTx2 iTx3;

monomialOfTargetI2 = monomialOfTargetI2 * 0.5 * k2 * powerSplitRatio * resistance;
monomialOfTargetI4 = monomialOfTargetI4 * 0.75 * k4 * powerSplitRatio ^ 2 * resistance ^ 2;

% group monomials
monomialOfTarget = [monomialOfTargetI2 monomialOfTargetI4];

% sum monomials to obtain target posynomial
targetFun = sum(monomialOfTarget);

% exponents of geometric means
exponentOfTarget = monomialOfTarget / targetFun;

end

