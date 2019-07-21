function [Solution] = wipt_decoupling(Transceiver, Channel, Solution)
% Function:
%   - characterizing the rate-energy region of MISO transmission based on the proposed WIPT architecture
%
% InputArg(s):
%   - Transceiver.k2: diode k-parameters
%   - Transceiver.k4: diode k-parameters
%   - Transceiver.txPower: average transmit power
%   - Transceiver.noisePower: average noise power
%   - Transceiver.resistance: antenna resistance
%   - Transceiver.rateThr: rate constraint per subband
%   - Channel.subband: number of subbands (subcarriers)
%   - Channel.subbandAmplitude: amplitude of channel impulse response
%   - Solution.powerSplitRatio: ratio for power transmission
%   - Solution.infoSplitRatio: ratio for information transmission
%   - Solution.powerAmplitude: amplitude of power waveform
%   - Solution.infoAmplitude: amplitude of information waveform
%
% OutputArg(s):
%   - Solution.powerAmplitude: amplitude of updated power waveform
%   - Solution.infoAmplitude: amplitude of updated information waveform
%   - Solution.current: maximum achievable DC current at the output of the harvester
%   - Solution.rate: mutual information based on the designed waveform
%
% Comments:
%   - decouple the design of the spatial and frequency domain weights
%   - significantly reduce the computational complexity as vectors rather than matrices are to be optimized numerically
%   - optimal for SISO but no guarantee for MISO
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19


v2struct(Transceiver, {'fieldNames', 'k2', 'k4', 'txPower', 'noisePower', 'resistance', 'rateThr', 'currentGainThr'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude'});
v2struct(Solution, {'fieldNames', 'powerSplitRatio', 'infoSplitRatio', 'powerAmplitude', 'infoAmplitude'});

% initialize
current = NaN;
rate = NaN;
isConverged = false;
isSolvable = true;
sumRateThr = subband * rateThr;

[~, ~, exponentOfTarget] = target_function_decoupling(Transceiver, Channel, Solution);
[~, ~, exponentOfMutualInfo] = mutual_information_decoupling(Transceiver, Channel, Solution);

while (~isConverged) && (isSolvable)
    clearvars t0 powerAmplitude infoAmplitude powerSplitRatio infoSplitRatio
    
    cvx_begin gp
        cvx_solver sedumi
        
        variable t0
        variable powerAmplitude(subband, 1) nonnegative
        variable infoAmplitude(subband, 1) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function_decoupling(Transceiver, Channel, Solution);
        [~, monomialOfMutualInfo, ~] = mutual_information_decoupling(Transceiver, Channel, Solution);

        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ sumRateThr * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end
    
    % update achievable rate and power successively
    if cvx_status == "Solved"
        [targetFun, ~, exponentOfTarget] = target_function_decoupling(subband, powerAmplitude, infoAmplitude, subbandAmplitude, k2, k4, powerSplitRatio, resistance);
        [rate, ~, exponentOfMutualInfo] = mutual_information_decoupling(subband, infoAmplitude, subbandAmplitude, noisePower, infoSplitRatio);
        isConverged = (targetFun - current) < currentGainThr;
        current = targetFun;
    else
        isSolvable = false;
    end
end

end

