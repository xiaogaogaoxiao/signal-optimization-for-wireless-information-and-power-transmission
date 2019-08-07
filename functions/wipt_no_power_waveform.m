function [Solution] = wipt_no_power_waveform(Transceiver, Channel, Solution)
% Function:
%   - characterize the rate-energy region of MISO transmission based on the proposed WIPT architecture
%
% InputArg(s):
%   - Transceiver.k2: diode k-parameters
%   - Transceiver.k4: diode k-parameters
%   - Transceiver.txPower: average transmit power
%   - Transceiver.noisePower: average noise power
%   - Transceiver.resistance: antenna resistance
%   - Transceiver.rateThr: rate constraint per subband
%   - Transceiver.currentGainThr: iteration threshold for current gain
%   - Channel.subband: number of subbands (subcarriers)
%   - Channel.subbandAmplitude: amplitude of channel impulse response
%   - Solution.infoAmplitude: amplitude of information waveform
%   - Solution.powerSplitRatio: ratio for power transmission
%   - Solution.infoSplitRatio: ratio for information transmission
%
% OutputArg(s):
%   - Solution.infoAmplitude: amplitude of updated information waveform
%   - Solution.powerSplitRatio: ratio for power transmission
%   - Solution.infoSplitRatio: ratio for information transmission
%   - Solution.current: maximum achievable DC current at the output of the harvester
%   - Solution.rate: mutual information based on the designed waveform
%
% Comments:
%   - all power allocated to information waveform
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19


v2struct(Transceiver, {'fieldNames', 'k2', 'k4', 'txPower', 'noisePower', 'resistance', 'rateThr', 'currentGainThr'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude'});
v2struct(Solution, {'fieldNames', 'powerSplitRatio', 'infoSplitRatio', 'infoAmplitude'});

% initialize
current = NaN;
rate = NaN;
isConverged = false;
isSolvable = true;
sumRateThr = subband * rateThr;

[~, ~, exponentOfTarget] = target_function_no_power_waveform(k2, k4, resistance, subbandAmplitude, subband, infoAmplitude, powerSplitRatio);
[~, ~, exponentOfMutualInfo] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);

while (~isConverged) && (isSolvable)
    try
        cvx_begin gp
            cvx_solver mosek

            variable t0
            variable infoAmplitude(subband, 1) nonnegative
            variable powerSplitRatio nonnegative
            variable infoSplitRatio nonnegative

            % formulate the expression of monomials
            [~, monomialOfTarget, ~] = target_function_no_power_waveform(k2, k4, resistance, subbandAmplitude, subband, infoAmplitude, powerSplitRatio);
            [~, monomialOfMutualInfo, ~] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);

            minimize (1 / t0)
            subject to
                0.5 * (norm(infoAmplitude, 'fro') ^ 2) <= txPower;
                t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
                2 ^ sumRateThr * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
                powerSplitRatio + infoSplitRatio <= 1;
        cvx_end
    catch
        isSolvable = false;
    end
    
    % update achievable rate and power successively
    if cvx_status == "Solved"
        [targetFun, ~, exponentOfTarget] = target_function_no_power_waveform(k2, k4, resistance, subbandAmplitude, subband, infoAmplitude, powerSplitRatio);
        [rate, ~, exponentOfMutualInfo] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);
        isConverged = (targetFun - current) < currentGainThr;
        current = targetFun;
        
        Solution.infoAmplitude = infoAmplitude;
        Solution.powerSplitRatio = powerSplitRatio;
        Solution.infoSplitRatio = infoSplitRatio;
        Solution.current = current;
        Solution.rate = rate;
    else
        isSolvable = false;
end

end

