function [SolutionSuperposedWaveform, SolutionNoPowerWaveform] = initialize_algorithm(Transceiver, Channel)
% Function:
%   - initialize resource allocation with matched filers
%
% InputArg(s):
%   - Transceiver.txPower: average transmit power
%   - Channel.subbandAmplitude: amplitude of channel impulse response
%
% OutputArg(s):
%   - SolutionSuperposedWaveform: initial amplitude corresponding to the algorithm of superposed waveform
%   - SolutionNoPowerWaveform: initial amplitude corresponding to the algorithm of no power waveform
%
% Comments:
%   - initialize power and information waveforms with matched filers
%
% Author & Date: Yang (i@snowztail.com) - 22 Jul 19


v2struct(Transceiver, {'fieldNames', 'txPower'});
v2struct(Channel, {'fieldNames', 'subbandAmplitude'});

% initialize results
rate = NaN;
current = NaN;
% ratio for power transmission
powerSplitRatio = 0.5;
% ratio for information transmission
infoSplitRatio = 1 - powerSplitRatio;


% superposed waveforms
powerAmplitude = subbandAmplitude / norm(subbandAmplitude, 'fro') * sqrt(txPower);
infoAmplitude = subbandAmplitude / norm(subbandAmplitude, 'fro') * sqrt(txPower);
SolutionSuperposedWaveform = v2struct(rate, current, powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);

% no power waveform
powerAmplitude = zeros(size(powerAmplitude)) + eps;
infoAmplitude = subbandAmplitude / norm(subbandAmplitude, 'fro') * sqrt(txPower) * sqrt(2);
SolutionNoPowerWaveform = v2struct(rate, current, powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);

end

