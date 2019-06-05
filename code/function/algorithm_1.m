function [outputArg1,outputArg2] = algorithm_1(sPower, sInfo, rho, zDc)
%ALGORITHM_1 Summary of this function goes here
%   Detailed explanation goes here

% initialise
iOut = 0; zDcPrev = 0;

% auxiliary variable and monomial terms in the posynomial zDc
variable t0 g(nTerm)

minimize 1 / t0
subject to
0.5 * (norm(sPower, 'fro') + norm(sInfo, 'fro')) < pTx
t0 / zDc <= 1
end

