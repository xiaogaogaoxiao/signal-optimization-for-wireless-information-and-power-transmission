function [current, rate] = wipt_no_power_waveform(nSubbands, channelAmplitude, k2, k4, txPower, noisePower, resistance, minSubbandRate, minCurrentGain)
% Function:
%   - characterizing the rate-energy region of MISO transmission based on the proposed WIPT architecture
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - channelAmplitude: amplitude of channel impulse response
%   - k2, k4: diode k-parameters
%   - txPower: average transmit power
%   - noisePower: average noise power
%   - resistance: antenna resistance
%   - minSubbandRate: rate constraint per subband
%
% OutputArg(s):
%   - current: maximum achievable DC current at the output of the harvester
%   - rate: mutual information based on the designed waveform
%
% Comments:
%   - all power allocated to information waveform
%   - optimal for SISO but no guarantee for MISO
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19


% initialize
current = 0;
isConverged = false;
isSolvable = true;

powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;

minSumRate = nSubbands * minSubbandRate;

% matched filters
powerAmplitude = zeros(size(channelAmplitude)) + eps;
infoAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);

[~, ~, exponentOfTarget] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
[~, ~, exponentOfMutualInfo] = mutual_information_decoupling(nSubbands, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

while (~isConverged) && (isSolvable)
    clearvars t0 infoAmplitude powerSplitRatio infoSplitRatio
    
    cvx_begin gp
        cvx_solver mosek
        
        variable t0
        variable infoAmplitude(nSubbands, 1) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [~, monomialOfMutualInfo, ~] = mutual_information_decoupling(nSubbands, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ minSumRate * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end
    
    % update achievable rate and power successively
    if cvx_status == "Solved"
        [targetFun, ~, exponentOfTarget] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [rate, ~, exponentOfMutualInfo] = mutual_information_decoupling(nSubbands, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
        isConverged = (targetFun - current) < minCurrentGain;
        current = targetFun;
    else
        current = NaN;
        rate = NaN;
        isSolvable = false;
    end
end

end

