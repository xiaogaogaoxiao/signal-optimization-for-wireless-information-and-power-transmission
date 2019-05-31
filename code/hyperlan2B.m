function [h_tap] = hyperlan2B()
% Function:
%   - simulate a multipath channel based on HIPERLAN/2, model B
%
% InputArg(s):
%   - none
%
% OutputArg(s):
%   - h_tap: 10 ns impulse response
%
% Comments:
%   - corresponds to typical large open space and office environments for
%   NLOS conditions and 100 ns average rms delay spread
%
% Author & Date: Yang (i@snowztail.com) - 31 May 19


% delay in 10 ns
tau_tap = [0 1 2 3 5 8 11 14 18 23 28 33 38 43 49 56 64 73];

% average relative power
beta_tap_db = [-2.6 -3.0 -3.5 -3.9 0.0 -1.3 -2.6 -3.9 -3.4 -5.6 -7.7 -9.9 -12.1 -14.3 -15.4 -18.4 -20.7 -24.6];
beta_tap(tau_tap + 1) = db2pow(beta_tap_db);

% normalise multipath response
beta_tap = beta_tap / sum(beta_tap);

% model taps as i.i.d. CSCG variables
fading = sqrt(1 / 2) * (randn(size(beta_tap)) + 1i * randn(size(beta_tap)));
h_tap = sqrt(beta_tap) .* fading;
