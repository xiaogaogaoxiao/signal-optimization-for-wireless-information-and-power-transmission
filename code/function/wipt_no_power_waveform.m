function [current, rate] = wipt_no_power_waveform(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio)
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
%   - no multisine power waveform
%
% Author & Date: Yang (i@snowztail.com) - 17 Jun 19

% initialize with matched filters
infoAmplitude = channelAmplitude;
powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;
current = 0;
[~, ~, exponentOfTarget] = target_function_no_power_waveform(nSubbands, nTxs, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
[~, ~, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

% iterate until optimum
for iIter = 1: maxIter
    clearvars t0 infoAmplitude powerSplitRatio infoSplitRatio
    
    cvx_begin gp
        cvx_solver mosek
        
        variable t0
        variable infoAmplitude(nSubbands, nTxs) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function_no_power_waveform(nSubbands, nTxs, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [~, monomialOfMutualInfo, ~] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * norm(infoAmplitude, 'fro') ^ 2 <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ minRate * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end
    
    % update achievable rate and power successively
    [targetFun, ~, exponentOfTarget] = target_function_no_power_waveform(nSubbands, nTxs, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
    [rate, ~, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
    
    % stopping criteria
    doExit = (targetFun - current) / current < minCurrentGainRatio;
    
    % update optimum DC current
    current = targetFun;
    
    if doExit
        break;
    end
end

end

