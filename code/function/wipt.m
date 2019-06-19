function [current, rate] = wipt(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio, minCurrentGain)
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
%   - maxIter: max number of iterations for sequential convex optimization
%   - minRate: rate constraint
%   - minCurrentGainRatio: minimum gain ratio of the harvested current in each iteration
%
% OutputArg(s):
%   - current: maximum achievable DC current at the output of the harvester
%   - rate: mutual information based on the designed waveform
%
% Comments:
%   - a general approach
%   - the power is maximized but the rate can be higher than the constraint
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19

% initialize with matched filters
powerAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);
infoAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);
powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;
current = 0;
[~, ~, exponentOfTarget] = target_function(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
[~, ~, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

% iterate until optimum
for iIter = 1: maxIter
    clearvars t0 powerAmplitude infoAmplitude powerSplitRatio infoSplitRatio
    
    cvx_begin gp
        cvx_solver sedumi
        
        variable t0
        variable powerAmplitude(nSubbands, nTxs) nonnegative
        variable infoAmplitude(nSubbands, nTxs) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [~, monomialOfMutualInfo, ~] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ minRate * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end
    
    % update achievable rate and power successively
    [targetFun, ~, exponentOfTarget] = target_function(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
    [rate, ~, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
    
    % stopping criteria
    doExit = (targetFun - current) / current < minCurrentGainRatio || (targetFun - current) < minCurrentGain;
    
    % update optimum DC current
    current = targetFun;
    
    if doExit
        break;
    end
end

end

