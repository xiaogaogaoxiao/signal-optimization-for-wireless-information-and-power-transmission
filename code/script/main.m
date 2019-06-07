initialise; config;

% simulate multipath channel based on tapped-delay line model
[impulseResponse] = impulse_response(nSubbands, nTxs, carrierFreq);
% obtain the absolute value of channel impulse response
channelAmplitude = abs(impulseResponse);

cvx_begin gp
    
    variable powerAmplitude(nSubbands, nTxs) nonnegative
    variable infoAmplitude(nSubbands, nTxs) nonnegative
    
    % formulate the target posymonial and monomials
    [target, monomialOfTarget] = target(nSubbands, nTxs, powerAmplitude, infoAmplitude, channelAmplitude, k2, k4, splitRatio, resistance);
    % formulate the mutual information and monomial components of posynomials that contribute to it
    [mutualInfo, monomialOfMutualInfo] = mutual_information(nSubbands, nTxs, infoAmplitude, channelAmplitude, noisePower, splitRatio);
    
    
cvx_end
