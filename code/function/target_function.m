function [zDc, g, nTerm] = target_function(nSubband, nTx, sPower, sInfo, psiPower, psiInfo, aChannel, k2, k4, rho, rAntenna)
% Function:
%   - link the target function zDc to multicarrier unmodulated (multisine)
%   power waveform and modulated information waveform
%   - decomposite zDc as sum of monomials
%
% InputArg(s):
%   - nSubband: number of subbands/subcarriers
%   - nTx: number of transmit antennas
%   - sPower: optimum power amplitude as CVX variable
%   - sInfo: optimum information amplitude as CVX variable
%   - psiPower: combined (channel + power waveform) phase
%   - psiInfo: combined (channel + information waveform) phase
%   - aChannel: amplitude of channel impulse response
%   - k2, k4: diode k-parameters
%   - rho: power splitting ratio
%   - rAntenna: antenna resistance
%
% OutputArg(s):
%   - zDc: target posynomial to maximise the output current
%   - g: monomial terms as components of posynomial zDc
%   - nTerm: number of terms in the posynomial zDc (K)
%
% Comments:
%   - only consider the most fundamental nonlinear model (i.e. truncate at
%     order 4)
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms in each expression
nTermPower2 = nSubband * nTx ^ 2;
nTermPower4 = nSubband * (2 * nSubband ^ 2 + 1) / 3 * nTx ^ 4;
nTermInfo2 = nSubband * nTx ^ 2;
nTermInfo4 = (nSubband * nTx ^ 2) ^ 2;
nTermPower2Info2 = (nSubband * nTx ^ 2) ^ 2;

% number of terms in the result posynomial (K)
nTerm = nTermPower2 + nTermPower4 + nTermInfo2 + nTermInfo4 + nTermPower2Info2;

cvx_begin gp
variables gPower2(nTermPower2) gPower4(nTermPower4) gInfo2(nTermInfo2) gInfo4(nTermInfo4) gPower2Info2(nTermPower2Info2)

% time-average of power (multisine) signal to the second order
yPower2 = 0; iTerm = 0;
for n = 1: nSubband
    for m0 = 1: nTx
        for m1 = 1: nTx
            yPower2 = yPower2 + 0.5 * sPower(n, m0) * sPower(n, m1) * aChannel(n, m0) * aChannel(n, m1) * cos(psiPower(n, m0) - psiPower(n, m0));
            iTerm = iTerm + 1;
            gPower2(iTerm) = 0.5 * k2 * rho * rAntenna * sPower(n, m0) * aChannel(n, m0) * sPower(n, m1) * aChannel(n, m1) * cos(psiPower(n, m0) - psiPower(n, m0));
        end
    end
end
clearvars n m0 m1;

% time-average of power (multisine) signal to the fourth order
yPower4 = 0; iTerm = 0;
for n0 = 1: nSubband
    for n1 = 1: nSubband
        for n2 = 1: nSubband
            n3 = n0 + n1 - n2;
            if n3 < 1 || n3 > nSubband
                continue;
            else
                for m0 = 1: nTx
                    for m1 = 1: nTx
                        for m2 = 1: nTx
                            for m3 = 1: nTx
                                yPower4 = yPower4 + 0.375 * (sPower(n0, m0) * aChannel(n0, m0)) * (sPower(n1, m1) * aChannel(n1, m1)) * (sPower(n2, m2) * aChannel(n2, m2)) * (sPower(n3, m3) * aChannel(n3, m3)) * cos(psiPower(n0, m0) + psiPower(n1, m1) - psiPower(n2, m2) - psiPower(n3, m3));
                                iTerm = iTerm + 1;
                                gPower4(iTerm) = 0.375 * k4 * rho ^ 2 * rAntenna ^ 2 *  (sPower(n0, m0) * aChannel(n0, m0)) * (sPower(n1, m1) * aChannel(n1, m1)) * (sPower(n2, m2) * aChannel(n2, m2)) * (sPower(n3, m3) * aChannel(n3, m3)) * cos(psiPower(n0, m0) + psiPower(n1, m1) - psiPower(n2, m2) - psiPower(n3, m3));
                            end
                        end
                    end
                end
            end
        end
    end
end
clearvars n0 n1 n2 n3 m0 m1 m2 m3;

% expectation of time-average of information (modulated) signal to the second order
yInfo2 = 0; iTerm = 0;
for n = 1: nSubband
    for m0 = 1: nTx
        for m1 = 1: nTx
            yInfo2 = yInfo2 + 0.5 * sInfo(n, m0) * sInfo(n, m1) * aChannel(n, m0) * aChannel(n, m1) * cos(psiInfo(n, m0) - psiInfo(n, m0));
            iTerm = iTerm + 1;
            gInfo2(iTerm) = 0.5 * k2 * rho * rAntenna * sInfo(n, m0) * aChannel(n, m0) * sInfo(n, m1) * aChannel(n, m1) * cos(psiInfo(n, m0) - psiInfo(n, m0));
        end
    end
end
clearvars n m0 m1;

% expectation of time-average of information (modulated) signal to the fourth order
yInfo4 = 0; iTerm = 0;
for n0 = 1: nSubband
    for n1 = 1: nSubband
        for m0 = 1: nTx
            for m1 = 1: nTx
                for m2 = 1: nTx
                    for m3 = 1: nTx
                        yInfo4 = yInfo4 + 0.75 * (sInfo(n0, m0) * aChannel(n0, m0)) * (sInfo(n0, m2) * aChannel(n0, m2)) * (sInfo(n1, m1) * aChannel(n1, m1)) * (sInfo(n1, m3) * aChannel(n1, m3)) * cos(psiInfo(n0, m0) + psiInfo(n1, m1) - psiInfo(n0, m2) - psiInfo(n1, m3));
                        iTerm = iTerm + 1;
                        gInfo4(iTerm) = 0.75 * k4 * rho ^ 2 * rAntenna ^ 2 * (sInfo(n0, m0) * aChannel(n0, m0)) * (sInfo(n0, m2) * aChannel(n0, m2)) * (sInfo(n1, m1) * aChannel(n1, m1)) * (sInfo(n1, m3) * aChannel(n1, m3)) * cos(psiInfo(n0, m0) + psiInfo(n1, m1) - psiInfo(n0, m2) - psiInfo(n1, m3));
                    end
                end
            end
        end
    end
end
clearvars n0 n1 m0 m1 m2 m3;

% combined terms
iTermPower2Info2 = 0;
for iTermPower = 1: nTermPower2
    for iTermInfo = 1: nTermInfo2
        iTermPower2Info2 = iTermPower2Info2 + 1;
        gPower2Info2(iTermPower2Info2) = 6 * k4 / k2 ^ 2 * gPower2(iTermPower) * gInfo2(iTermInfo);
    end
end

g = [gPower2; gPower4; gInfo2; gInfo4; gPower2Info2];

% sum monomials to target posynomial function
zDc = sum(g);
% zDc = k2 * rho * rAntenna * yPower2 + k4 * rho ^ 2 * rAntenna ^ 2 * yPower4 + k2 * rho * rAntenna * yInfo2 + k4 * rho ^ 2 * rAntenna ^ 2 * yInfo4 + 6 * k4 * rho ^ 2 * rAntenna ^ 2 * yPower2 * yInfo2;

cvx_end
end
