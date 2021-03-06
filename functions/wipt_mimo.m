function [Solution] = wipt_mimo(Transceiver, Channel, Solution)
% Function:
%   - characterize the rate-energy region based on the proposed WIPT architecture
%
% InputArg(s):
%   - Transceiver.k2: diode k-parameters
%   - Transceiver.k4: diode k-parameters
%   - Transceiver.tx: number of transmit antennas
%   - Transceiver.rx: number of receive antennas
%   - Transceiver.txPower: average transmit power
%   - Transceiver.noisePower: average noise power
%   - Transceiver.resistance: antenna resistance
%   - Transceiver.rateThr: rate constraint per subband
%   - Transceiver.currentGainThr: iteration threshold for current gain
%   - Transceiver.beamformPhase: the beamforming phase
%   - Channel.subband: number of subbands (subcarriers)
%   - Channel.subbandAmplitude: amplitude of channel impulse response
%   - Channel.subbandPhase: multipath channel phase on the subbands
%   - Solution.powerAmplitude: amplitude of power waveform
%   - Solution.infoAmplitude: amplitude of information waveform
%   - Solution.powerSplitRatio: ratio for power transmission
%   - Solution.infoSplitRatio: ratio for information transmission
%
% OutputArg(s):
%   - Solution.powerAmplitude: amplitude of updated power waveform
%   - Solution.infoAmplitude: amplitude of updated information waveform
%   - Solution.powerSplitRatio: ratio for power transmission
%   - Solution.infoSplitRatio: ratio for information transmission
%   - Solution.current: maximum achievable DC current at the output of the harvester
%   - Solution.rate: mutual information based on the designed waveform
%
% Comments:
%   - suboptimal for multiple output antennas
%   - phases are initialized to the phases of the dominant right singular vectors
%
% Author & Date: Yang (i@snowztail.com) - 01 Aug 19


v2struct(Transceiver, {'fieldNames', 'k2', 'k4', 'tx', 'rx' 'txPower', 'noisePower', 'resistance', 'rateThr', 'currentGainThr', 'beamformPhase'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude', 'subbandPhase'});
v2struct(Solution, {'fieldNames', 'powerSplitRatio', 'infoSplitRatio', 'powerAmplitude', 'infoAmplitude'});

% initialize
current = NaN;
rate = NaN;
isConverged = false;
isSolvable = true;
sumRateThr = subband * rateThr;

% suboptimal beamforming phase
powerPhase = subbandPhase + beamformPhase;
infoPhase = subbandPhase + beamformPhase;

[~, ~, positiveExponentOfTarget] = target_function_mimo(k2, k4, tx, rx, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerPhase, infoPhase, powerSplitRatio);
[~, ~, ~, positiveExponentOfMi] = mutual_information_mimo(tx, rx, noisePower, subband, subbandAmplitude, infoAmplitude, infoPhase, infoSplitRatio);

while (~isConverged) && (isSolvable)
    try
        cvx_begin gp
            cvx_solver mosek

            variable t0
            variable powerAmplitude(subband, tx) nonnegative
            variable infoAmplitude(subband, tx) nonnegative
            variable powerSplitRatio nonnegative
            variable infoSplitRatio nonnegative

            % formulate the expression of monomials
            [~, negativePosynomialOfTarget, positiveMonomialOfTarget, ~] = target_function_mimo(k2, k4, tx, rx, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerPhase, infoPhase, powerSplitRatio);
            [~, negativePosynomialOfMi, positiveMonomialOfMi, ~] = mutual_information_mimo(tx, rx, noisePower, subband, subbandAmplitude, infoAmplitude, infoPhase, infoSplitRatio);

            minimize (1 / t0)
            subject to
                0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
                (t0 + negativePosynomialOfTarget) * prod((positiveMonomialOfTarget ./ positiveExponentOfTarget) .^ (-positiveExponentOfTarget)) <= 1;
                (2 ^ sumRateThr + negativePosynomialOfMi) * prod((positiveMonomialOfMi ./ positiveExponentOfMi) .^ (-positiveExponentOfMi)) <= 1;
                powerSplitRatio + infoSplitRatio <= 1;
        cvx_end
    catch
        isSolvable = false;
    end
    
    % update achievable rate and power successively
    if cvx_status == "Solved"
        [targetFun, ~, ~, positiveExponentOfTarget] = target_function_mimo(k2, k4, tx, rx, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerPhase, infoPhase, powerSplitRatio);
        [rate, ~, ~, positiveExponentOfMi] = mutual_information_mimo(tx, rx, noisePower, subband, subbandAmplitude, infoAmplitude, infoPhase, infoSplitRatio);
        isConverged = (targetFun - current) < currentGainThr;
        current = targetFun;
        
%         Solution = v2struct(powerAmplitude, infoAmplitude, powerSplitRatio, infoSplitRatio, current, rate);
        Solution.current = current; Solution.rate = rate;
    else
        isSolvable = false;
    end
end

end

