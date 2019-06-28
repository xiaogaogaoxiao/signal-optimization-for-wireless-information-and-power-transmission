function [tapDelay, tapGain] = hiperlan2_B()
% Function:
%   - simulate a tapped-delay line based on HIPERLAN/2 model B
%
% InputArg(s):
%   - none
%
% OutputArg(s):
%   - tapDelay: tap (path) delay
%   - tapGain: complex tap (path) gain
%
% Comments:
%   - corresponds to typical large open space and office environments for NLOS conditions and 100 ns average rms delay spread
%
% Author & Date: Yang (i@snowztail.com) - 31 May 19


tapDelay = [0 10 20 30 50 80 110 140 180 230 280 330 380 430 490 560 640 730] * 1e-9;
tapPowerDb = [-2.6 -3.0 -3.5 -3.9 0.0 -1.3 -2.6 -3.9 -3.4 -5.6 -7.7 -9.9 -12.1 -14.3 -15.4 -18.4 -20.7 -24.6];
tapPower = db2pow(tapPowerDb);

% model taps as i.i.d. CSCG variables
tapGain = sqrt(tapPower) .* (sqrt(1 / 2) * (randn(size(tapPower)) + 1i * randn(size(tapPower))));

end

