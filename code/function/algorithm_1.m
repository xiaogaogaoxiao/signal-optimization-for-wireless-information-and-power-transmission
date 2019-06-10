function [mutualInfo] = algorithm_1(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, resistance, iterMax, rateMin)
%ALGORITHM_1 Summary of this function goes here
%   Detailed explanation goes here




% initialize (matched filters)
powerAmplitude = channelAmplitude;
infoAmplitude = channelAmplitude;
powerSplitRatio = 0.5;
infoSplitRatio = 0.5;

for iIter = 1: iterMax
    % formulate the target posymonial and monomials
    [targetFun, monomialOfTarget, exponentOfTarget] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, powerSplitRatio, resistance);
    % formulate the mutual information and monomial components of posynomials that contribute to it
    [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, infoSplitRatio);
    % for exponents only; updated in each iteration
    clearvars t0 powerAmplitude infoAmplitude powerSplitRatio infoSplitRatio
    
    %% optimization
    cvx_begin gp
    
    variable t0
    variable powerAmplitude(nSubbands, nTxs) nonnegative
    variable infoAmplitude(nSubbands, nTxs) nonnegative
    variable powerSplitRatio nonnegative
    variable infoSplitRatio nonnegative
    
    minimize (1 / t0)
    subject to
        0.5 * (sum(sum(square_abs(powerAmplitude))) + sum(sum(square_abs(infoAmplitude)))) <= txPower;
%         0.5 * (power(norm(powerAmplitude, 'fro'),2  + sum(sum(square_abs(infoAmplitude)))) <= txPower;
        t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
        2 ^ rateMin * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
        powerSplitRatio + infoSplitRatio <= 1;
    
    cvx_end
    
end

end

