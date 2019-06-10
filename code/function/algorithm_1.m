function [targetFun, mutualInfo] = algorithm_1(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, iterMax, rateMin)
%ALGORITHM_1 Summary of this function goes here
%   Detailed explanation goes here




% initialize (matched filters)
powerAmplitude = channelAmplitude;
infoAmplitude = channelAmplitude;
powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;

% iterate until optimum
for iIter = 1: iterMax
    %% condition [known]
    % calculate the exponent of geometric mean based on existing solutions
    [~, ~, exponentOfTarget] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
    [~, ~, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
    
    clearvars powerAmplitude infoAmplitude powerSplitRatio infoSplitRatio
    %% optimization [unknown]
    cvx_begin gp

        variable t0
        variable powerAmplitude(nSubbands, nTxs) nonnegative
        variable infoAmplitude(nSubbands, nTxs) nonnegative
        variable powerSplitRatio nonnegative
        variable infoSplitRatio nonnegative

        % formulate the expression of monomials
        [~, monomialOfTarget, ~] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
        [~, monomialOfMutualInfo, ~] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);

        minimize (1 / t0)
        subject to
            0.5 * (sum(sum(square_abs(powerAmplitude))) + sum(sum(square_abs(infoAmplitude)))) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ rateMin * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            powerSplitRatio + infoSplitRatio <= 1;

    cvx_end
    
[targetFun, ~, ~] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
[mutualInfo, ~, ~] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
end

end

