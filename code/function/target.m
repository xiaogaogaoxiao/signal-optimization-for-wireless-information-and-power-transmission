function [target, monomialOfTarget] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, splitRatio, resistance)
% Function:
%   - formulate the target proportional to the output current as a function of amplitudes of multicarrier unmodulated (multisine) power waveform and modulated information waveform
%   - decomposite target posynomial as sum of monomials
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - powerAmplitude: optimum amplitude assigned to power waveform [CVX variable]
%   - infoAmplitude: optimum amplitude assigned to information waveform [CVX variable]
%   - channelAmplitude: amplitude of channel impulse response
%   - k2, k4: diode k-parameters
%   - splitRatio: power splitting ratio
%   - resistance: antenna resistance
%
% OutputArg(s):
%   - target: target posynomial (zDc) that proportional to the output current
%   - monomialOfTarget: monomials (g) as components of the target posynomial
%
% Comments:
%   - only consider the most fundamental nonlinear model (i.e. truncate at the fourth order)
%   - for the single-user case, the optimum phases of power and information waveforms equal the negative phase of channel impulse response
%
% Author & Date: Yang (i@snowztail.com) - 04 Jun 19


% number of terms in each expression
nTermsP2 = nSubbands * nTxs ^ 2;
nTermsP4 = nSubbands * (2 * nSubbands ^ 2 + 1) / 3 * nTxs ^ 4;
nTermsI2 = nSubbands * nTxs ^ 2;
nTermsI4 = (nSubbands * nTxs ^ 2) ^ 2;
nTermsP2I2 = (nSubbands * nTxs ^ 2) ^ 2;

cvx_begin gp

    variables monomialOfTargetP2(nTermsP2) monomialOfTargetP4(nTermsP4) monomialOfTargetI2(nTermsI2) monomialOfTargetI4(nTermsI4) monomialOfTargetP2I2(nTermsP2I2)

    % monomials related to the time-average of power (multisine) signal to the second order
    iTermP2 = 0;
    for iSubband = 1: nSubbands
        for iTx0 = 1: nTxs
            for iTx1 = 1: nTxs
                iTermP2 = iTermP2 + 1;
                monomialOfTargetP2(iTermP2) = 0.5 * k2 * splitRatio * resistance * powerAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0) * powerAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1);
            end
        end
    end
    clearvars iSubband iTx0 iTx1;

    % monomials related to the time-average of power (multisine) signal to the fourth order
    iTermP4 = 0;
    for iSubband0 = 1: nSubbands
        for iSubband1 = 1: nSubbands
            for iSubband2 = 1: nSubbands
                iSubband3 = iSubband0 + iSubband1 - iSubband2;
                if iSubband3 < 1 || iSubband3 > nSubbands
                    continue;
                else
                    for iTx0 = 1: nTxs
                        for iTx1 = 1: nTxs
                            for iTx2 = 1: nTxs
                                for iTx3 = 1: nTxs
                                    iTermP4 = iTermP4 + 1;
                                    monomialOfTargetP4(iTermP4) = 0.375 * k4 * splitRatio ^ 2 * resistance ^ 2 *  (powerAmplitude(iSubband0, iTx0) * channelAmplitude(iSubband0, iTx0)) * (powerAmplitude(iSubband1, iTx1) * channelAmplitude(iSubband1, iTx1)) * (powerAmplitude(iSubband2, iTx2) * channelAmplitude(iSubband2, iTx2)) * (powerAmplitude(iSubband3, iTx3) * channelAmplitude(iSubband3, iTx3));
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    clearvars iSubband0 iSubband1 iSubband2 iSubband3 iTx0 iTx1 iTx2 iTx3;

    % monomials related to the expectation of time-average of information (modulated) signal to the second order
    iTermI2 = 0;
    for iSubband = 1: nSubbands
        for iTx0 = 1: nTxs
            for iTx1 = 1: nTxs
                iTermI2 = iTermI2 + 1;
                monomialOfTargetI2(iTermI2) = 0.5 * k2 * splitRatio * resistance * infoAmplitude(iSubband, iTx0) * channelAmplitude(iSubband, iTx0) * infoAmplitude(iSubband, iTx1) * channelAmplitude(iSubband, iTx1);
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
                            monomialOfTargetI4(iTermI4) = 0.75 * k4 * splitRatio ^ 2 * resistance ^ 2 * (infoAmplitude(iSubband0, iTx0) * channelAmplitude(iSubband0, iTx0)) * (infoAmplitude(iSubband0, iTx2) * channelAmplitude(iSubband0, iTx2)) * (infoAmplitude(iSubband1, iTx1) * channelAmplitude(iSubband1, iTx1)) * (infoAmplitude(iSubband1, iTx3) * channelAmplitude(iSubband1, iTx3));
                        end
                    end
                end
            end
        end
    end
    clearvars iSubband0 iSubband1 iTx0 iTx1 iTx2 iTx3;

    % monomials related to the combined power-info terms
    iTermP2I2 = 0;
    for iTermP2 = 1: nTermsP2
        for iTermI2 = 1: nTermsI2
            iTermP2I2 = iTermP2I2 + 1;
            monomialOfTargetP2I2(iTermP2I2) = 6 * k4 / k2 ^ 2 * monomialOfTargetP2(iTermP2) * monomialOfTargetI2(iTermI2);
        end
    end

    monomialOfTarget = [monomialOfTargetP2; monomialOfTargetP4; monomialOfTargetI2; monomialOfTargetI4; monomialOfTargetP2I2];
    % sum monomials to obtain target posynomial
    target = sum(monomialOfTarget);

cvx_end

end

