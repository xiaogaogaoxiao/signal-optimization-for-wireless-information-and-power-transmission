function [Solution] = wipt_papr(Transceiver, Channel, Solution)
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
%   - decouple the design of the spatial and frequency domain weights
%   - significantly reduce the computational complexity as vectors rather than matrices are to be optimized numerically
%   - optimal for SISO but no guarantee for MISO
%
% Author & Date: Yang (i@snowztail.com) - 29 Jul 19






v2struct(Transceiver, {'fieldNames', 'k2', 'k4', 'txPower', 'noisePower', 'resistance', 'rateThr', 'currentGainThr', 'oversampleFactor', 'papr'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude', 'subbandPhase', 'sampleFrequency', 'gapFrequency'});
v2struct(Solution, {'fieldNames', 'powerSplitRatio', 'infoSplitRatio', 'powerAmplitude', 'infoAmplitude'});

% initialize
current = NaN;
rate = NaN;
isConverged = false;
isSolvable = true;
sumRateThr = subband * rateThr;

% oversampling
nOversamples = subband * oversampleFactor;
samplePeriod = 1 / gapFrequency;
positivePosynomial = cell(1, nOversamples);
negativeMonomial = cell(1, nOversamples);
negativeExponent = cell(1, nOversamples);

[~, ~, exponentOfTarget] = target_function_decoupling(k2, k4, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerSplitRatio);
[~, ~, exponentOfMutualInfo] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);

for iOversample = 1: nOversamples
    sampleTime = (iOversample) * samplePeriod / subband / oversampleFactor;
    [~, ~, negativeExponent{iOversample}] = signomial(subband, powerAmplitude, subbandPhase, sampleFrequency, sampleTime, papr);
end

while (~isConverged) && (isSolvable)
    cvx_begin gp
        cvx_solver sedumi
        
        variable t0
        variable powerAmplitude(subband, 1) nonnegative
        variable infoAmplitude(subband, 1) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function_decoupling(k2, k4, resistance, subbandAmplitude, subband, powerAmplitude, infoAmplitude, powerSplitRatio);
        [~, monomialOfMutualInfo, ~] = mutual_information_decoupling(noisePower, subband, subbandAmplitude, infoAmplitude, infoSplitRatio);
        
        % PAPR constraints
        for iOversample = 1: nOversamples
            sampleTime = (iOversample - 1) * samplePeriod / subband / oversampleFactor;
            [positivePosynomial{iOversample}, negativeMonomial{iOversample}, ~] = signomial(subband, powerAmplitude, subbandPhase, sampleFrequency, sampleTime, papr);
        end
        
        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ sumRateThr * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
            for iOversample = 1: nOversamples
                positivePosynomial{iOversample} * prod((negativeMonomial{iOversample} ./ negativeExponent{iOversample}) .^ (-negativeExponent{iOversample})) <= 1;
            end
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







































end

