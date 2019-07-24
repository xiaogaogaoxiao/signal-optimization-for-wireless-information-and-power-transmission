function [SolutionDecouplingInit, SolutionLowerBoundInit, SolutionNoPowerWaveformInit] = initialize_algorithm(Transceiver, Channel)
% Function:
%   - initialize algorithms
%
% InputArg(s):
%   - Transceiver.txPower: average transmit power
%   - Channel.subbandAmplitude: amplitude of channel impulse response
%
% OutputArg(s):
%   - SolutionDecouplingInit: initial resource allocation corresponding to the algorithm of superposed waveform
%   - SolutionLowerBoundInit: initial resource allocation corresponding to the algorithm of superposed waveform with interference
%   - SolutionNoPowerWaveformInit: initial resource allocation corresponding to the algorithm of no power waveform
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

% initialize resource allocation with matched filers
powerAmplitude = subbandAmplitude / norm(subbandAmplitude, 'fro') * sqrt(txPower);
infoAmplitude = subbandAmplitude / norm(subbandAmplitude, 'fro') * sqrt(txPower);
% superposed waveforms
SolutionDecouplingInit = v2struct(rate, current, powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);
SolutionLowerBoundInit = v2struct(rate, current, powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);

% no power waveform
powerAmplitude = zeros(size(powerAmplitude)) + eps;
infoAmplitude = infoAmplitude * sqrt(2);
SolutionNoPowerWaveformInit = v2struct(rate, current, powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);

end

