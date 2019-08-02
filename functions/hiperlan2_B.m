function [Channel] = hiperlan2_B(Transceiver, Channel)
% Function:
%   - simulate a tapped-delay line based on HIPERLAN/2 model B
%
% InputArg(s):
%   - Transceiver.tx: number of transmit antenna
%   - Transceiver.rx: number of receive antenna
%
% OutputArg(s):
%   - Channel.tapDelay: tap delay
%   - Channel.tapGain: complex tap gain
%
% Comments:
%   - corresponds to typical largWe open space and office environments for NLOS conditions and 100 ns average rms delay spread
%
% Author & Date: Yang (i@snowztail.com) - 31 May 19


v2struct(Transceiver, {'fieldNames', 'tx', 'rx'});

tap = 18;
tapDelay = [0 10 20 30 50 80 110 140 180 230 280 330 380 430 490 560 640 730]' * 1e-9;
tapPowerDb = [-2.6 -3.0 -3.5 -3.9 0.0 -1.3 -2.6 -3.9 -3.4 -5.6 -7.7 -9.9 -12.1 -14.3 -15.4 -18.4 -20.7 -24.6]';
tapPower = db2pow(tapPowerDb);

% model taps as i.i.d. CSCG variables
tapGain = repmat(sqrt(tapPower / 2), [1, tx, rx]) .* (randn(tap, tx, rx) + 1i * randn(tap, tx, rx));

Channel.tapGain = tapGain;
Channel.tapDelay = tapDelay;

end

