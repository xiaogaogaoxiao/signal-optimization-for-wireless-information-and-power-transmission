function [current, rate] = wipt_lower_bound(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, minSubbandRate, minCurrentGain, maxIter)
% Function:
%   - characterizing the rate-energy region of MISO transmission based on the proposed WIPT architecture
%
% InputArg(s):
%   - nSubbands: number of subbands (subcarriers)
%   - nTxs: number of transmit antennas
%   - channelAmplitude: amplitude of channel impulse response
%   - k2, k4: diode k-parameters
%   - txPower: average transmit power
%   - noisePower: average noise power
%   - resistance: antenna resistance
%   - minSubbandRate: rate constraint per subband
%   - maxIter: max number of iterations for sequential convex optimization
%
% OutputArg(s):
%   - current: maximum achievable DC current
%   - rate: mutual information based on the designed waveform
%
% Comments:
%   - assume the power waveform is CSCG that creates an interference and rate loss
%   - optimal for SISO but no guarantee for MISO
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19


% initialize
current = NaN;
rate = NaN;
isConverged = false;
isSolvable = true;
iIter = 0;

powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;

minSumRate = nSubbands * minSubbandRate;

% matched filters
powerAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);
infoAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);

[~, ~, exponentOfTarget] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
[~, ~, ~, exponentOfMutualInfo] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

while (~isConverged) && (isSolvable)
    clearvars t0 powerAmplitude infoAmplitude powerSplitRatio infoSplitRatio
    iIter = iIter + 1;
    
    cvx_begin gp
        cvx_solver sedumi
        
        variable t0
        variable powerAmplitude(nSubbands, nTxs) nonnegative
        variable infoAmplitude(nSubbands, nTxs) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [~, monomialOfMutualInfo, posynomialOfPowerTerms, ~] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ minSumRate * prod((1 + infoSplitRatio / noisePower * posynomialOfPowerTerms) .* prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo), 2)) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end

    % update achievable rate and power successively
    if cvx_status == "Solved"
        [targetFun, ~, exponentOfTarget] = target_function_decoupling(nSubbands, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [rate, ~, ~, exponentOfMutualInfo] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
        isConverged = (targetFun - current) < minCurrentGain || iIter >= maxIter;
        current = targetFun;
    else
        isSolvable = false;
    end
end

end

