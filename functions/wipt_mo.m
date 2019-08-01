function [Solution] = wipt_mo(Transceiver, Channel, Solution)
% Function:
%   - characterize the rate-energy region based on the proposed WIPT architecture
%
% InputArg(s):
%   - Transceiver.k2: diode k-parameters
%   - Transceiver.k4: diode k-parameters
%   - Transceiver.tx: number of transmit antennas
%   - Transceiver.txPower: average transmit power
%   - Transceiver.noisePower: average noise power
%   - Transceiver.resistance: antenna resistance
%   - Transceiver.rateThr: rate constraint per subband
%   - Transceiver.currentGainThr: iteration threshold for current gain
%   - Transceiver.oversampleFactor: oversampleing factor
%   - Transceiver.papr: peak-to-average power ratio
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


v2struct(Transceiver, {'fieldNames', 'k2', 'k4', 'tx' 'txPower', 'noisePower', 'resistance', 'rateThr', 'currentGainThr'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude'});
v2struct(Solution, {'fieldNames', 'powerSplitRatio', 'infoSplitRatio', 'powerAmplitude', 'infoAmplitude'});

% initialize
current = NaN;
rate = NaN;
isConverged = false;
isSolvable = true;
sumRateThr = subband * rateThr;

[~, ~, exponentOfTarget] = target_function(k2, k4, tx, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerSplitRatio);
[~, ~, exponentOfMutualInfo] = mutual_information(tx, noisePower, subband, subbandAmplitude, infoAmplitude, infoPhase, infoSplitRatio);

while (~isConverged) && (isSolvable)
    cvx_begin gp
        cvx_solver sedumi
        
        variable t0
        variable powerAmplitude(subband, tx) nonnegative
        variable infoAmplitude(subband, tx) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function_decoupling(k2, k4, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerSplitRatio);
        [~, monomialOfMutualInfo, ~] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ sumRateThr * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end
    
    % update achievable rate and power successively
    if cvx_status == "Solved"
        [targetFun, ~, exponentOfTarget] = target_function_decoupling(k2, k4, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerSplitRatio);
        [rate, ~, exponentOfMutualInfo] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);
        isConverged = (targetFun - current) < currentGainThr;
        current = targetFun;
    else
        isSolvable = false;
    end
end

Solution.powerAmplitude = powerAmplitude;
Solution.infoAmplitude = infoAmplitude;
Solution.powerSplitRatio = powerSplitRatio;
Solution.infoSplitRatio = infoSplitRatio;
Solution.current = current;
Solution.rate = rate;

end

