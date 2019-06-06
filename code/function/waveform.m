function [zDc, iMutual] = waveform(nSubband, nTx, fCarrier, k2, k4, rho, rAntenna, pNoise, pTx)
%POWER_WAVEFORM Summary of this function goes here
%   Detailed explanation goes here

% simulate the multipath channel
[hChannel] = tdl_channel(nSubband, nTx, fCarrier);
% amplitude of the impulse response
aChannel = abs(hChannel);
%% waveform optimisation
cvx_begin gp
    % optimum power(tone) and information amplitude: to solve
    variable sPower(nSubband, nTx) nonnegative
    variable sInfo(nSubband, nTx) nonnegative
    % optimum tone phase: negative channel phase
    phiPower = -angle(hChannel); phiInfo = -angle(hChannel);
    % combined (channel + power/info waveform) phase: zero
    psiPower = phiPower + angle(hChannel); psiInfo = phiInfo + angle(hChannel);
    % model target function as posynomial
    [zDc, g, nTerm] = target_function(nSubband, nTx, sPower, sInfo, psiPower, psiInfo, aChannel, k2, k4, rho, rAntenna);
    % calculate the achievable mutual information
    [iMutual] = mutual_information(nSubband, nTx, sInfo, aChannel, pNoise, rho);
    
    
        
        

end
