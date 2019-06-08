function [mutualInfo] = algorithm_1(nSubbands, nTxs, channelAmplitude, k2, k4, txPower, noisePower, splitRatio, resistance, iterMax, rateMin)
%ALGORITHM_1 Summary of this function goes here
%   Detailed explanation goes here


cvx_begin gp
    
    % initialize
%     iIter = 0;
%     targetArray = 0;
    variable powerAmplitude(nSubbands, nTxs) nonnegative
    variable infoAmplitude(nSubbands, nTxs) nonnegative
    
    for iIter = 1: iterMax
        % formulate the target posymonial and monomials
        [targetFun, monomialOfTarget, exponentOfTarget] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, splitRatio, resistance);
        % formulate the mutual information and monomial components of posynomials that contribute to it
        [mutualInfo, monomialOfMutualInfo, exponentOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, splitRatio);
        
        variable t0
        
        minimize (1 / t0)
        
        subject to
            0.5 * (pow_abs(powerAmplitude, 2) + pow_abs(infoAmplitude, 2)) <= txPower;
            t0 * prod((monomialOfTarget ./ exponentOfTarget) .^ (-exponentOfTarget)) <= 1;
            2 ^ rateMin * prod(prod((monomialOfMutualInfo ./ exponentOfMutualInfo) .^ (-exponentOfMutualInfo))) <= 1;
            
        flag = 1;
    end
    
cvx_end

end

