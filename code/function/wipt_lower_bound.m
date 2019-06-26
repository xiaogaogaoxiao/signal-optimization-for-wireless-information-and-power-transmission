function [current, rate] = wipt_lower_bound(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, maxIter, minRate, minCurrentGainRatio, minCurrentGain)
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
%   - dcCurrent: maximum achievable DC current
%   - rate: mutual information based on the designed waveform
%
% Comments:
%   - assume the power waveform is CSCG that creates an interference and rate loss
%   - the power is maximized but the rate can be higher than the constraint
%   - assume same phase as in general case: optimal for single transmit antenna but no guarantee optimal for MISO
%
% Author & Date: Yang (i@snowztail.com) - 11 Jun 19


% initialize with matched filters
powerAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);
infoAmplitude = channelAmplitude / norm(channelAmplitude, 'fro') * sqrt(txPower);
powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;
current = 0;
    [~, ~, exponentOfTarget] = target_function(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
    [~, ~, ~, exponentOfMutualInfo] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

% iterate until optimum
for iIter = 1: maxIter
    clearvars t0 powerAmplitude infoAmplitude powerSplitRatio infoSplitRatio
    
    cvx_begin gp
        cvx_solver mosek
        
        variable t0
        variable powerAmplitude(nSubbands, nTxs) nonnegative
        variable infoAmplitude(nSubbands, nTxs) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target_function(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [~, monomialOfMutualInfo, posynomialOfPowerTerms, ~] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * (norm(powerAmplitude, 'fro') ^ 2 + norm(infoAmplitude, 'fro') ^ 2) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ minRate * prod((1 + infoSplitRatio / noisePower * posynomialOfPowerTerms) .* prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo), 2)) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;
    cvx_end

    % valid solution
    if cvx_status == "Solved"
        % update achievable rate and power successively
        [targetFun, ~, exponentOfTarget] = target_function(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [rate, ~, ~, exponentOfMutualInfo] = mutual_information_lower_bound(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
        % stopping criteria
        doExit = (targetFun - current) / current < minCurrentGainRatio || (targetFun - current) < minCurrentGain;
        % update optimum DC current
        current = targetFun;
        if doExit
            break;
        end
        % cannot meet the minimum rate requirement
    else
        current = NaN;
        rate = NaN;
        break;
    end
end

end

