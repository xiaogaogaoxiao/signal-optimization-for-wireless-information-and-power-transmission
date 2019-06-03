function [temp] = waveform(nSubband, nTx, fCarrier)
%POWER_WAVEFORM Summary of this function goes here
%   Detailed explanation goes here

% simulate the multipath channel
[hChannel] = channel(nSubband, nTx, fCarrier);
% amplitude of the impulse response
aChannel = abs(hChannel);
%% waveform optimisation
cvx_begin gp
% optimum tone amplitude: to solve
variables sPower(nSubband, nTx) sInfo(nSubband, nTx)
% optimum tone phase: negative channel phase
phiPower = -angle(hChannel); phiInfo = -angle(hChannel);
% combined (channel + power/info waveform) phase: zero
psiPower = phiPower + angle(hChannel); psiInfo = phiInfo + angle(hChannel);

% time-average of power(multisine) signal to the second order
yPower2 = 0;
for n = 1: nSubband
    for m0 = 1: nTx
        for m1 = 1: nTx
            yPower2 = yPower2 + 0.5 * sPower(n, m0) * sPower(n, m1) * aChannel(n, m0) * aChannel(n, m1) * cos(psiPower(n, m0) - psiPower(n, m0));
        end
    end
end
clearvars n m0 m1;

% time-average of power(multisine) signal to the fourth order
yPower4 = 0;
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
                            end
                        end
                    end
                end
            end
        end
    end
end
clearvars n0 n1 n2 n3 m0 m1 m2 m3;

% expectation of time-average of information(modulated) signal to the second order
yInfo2 = 0;
for n = 1: nSubband
    for m0 = 1: nTx
        for m1 = 1: nTx
            yInfo2 = yInfo2 + 0.5 * sInfo(n, m0) * sInfo(n, m1) * aChannel(n, m0) * aChannel(n, m1) * cos(psiInfo(n, m0) - psiInfo(n, m0));
        end
    end
end
clearvars n m0 m1;

% expectation of time-average of information(modulated) signal to the fourth order
yInfo4 = 0;
for n0 = 1: nSubband
    for n1 = 1: nSubband
        for m0 = 1: nTx
            for m1 = 1: nTx
                for m2 = 1: nTx
                    for m3 = 1: nTx
                        yInfo4 = yInfo4 + 0.75 * (sInfo(n0, m0) * aChannel(n0, m0)) * (sInfo(n0, m2) * aChannel(n0, m2)) * (sInfo(n1, m1) * aChannel(n1, m1)) * (sInfo(n1, m3) * aChannel(n1, m3)) * cos(psiInfo(n0, m0) + psiInfo(n1, m1) - psiInfo(n0, m2) - psiInfo(n1, m3));
                    end
                end
            end
        end
    end
end
clearvars n0 n1 m0 m1 m2 m3;
end

