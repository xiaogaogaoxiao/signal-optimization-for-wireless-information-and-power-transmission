function [SolutionDecoupling, SolutionLowerBound, SolutionNoPowerWaveform] = validate_solution(SolutionDecoupling, SolutionLowerBound, SolutionNoPowerWaveform)
%VALIDATE_SOLUTION Summary of this function goes here
%   Detailed explanation goes here
%% Initialize algorithms
% ratio for power transmission
powerSplitRatio = 0.5;
% ratio for information transmission
infoSplitRatio = 1 - powerSplitRatio;
% initialize resource allocation with matched filers
powerAmplitude = Channel.subbandAmplitude / norm(Channel.subbandAmplitude, 'fro') * sqrt(Transceiver.txPower);
infoAmplitude = Channel.subbandAmplitude / norm(Channel.subbandAmplitude, 'fro') * sqrt(Transceiver.txPower);
% superposed waveforms
SolutionDecoupling = v2struct(powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);
SolutionLowerBound = v2struct(powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);
% no power waveform
powerAmplitude = zeros(size(powerAmplitude)) + eps;
infoAmplitude = infoAmplitude * sqrt(2);
SolutionNoPowerWaveform = v2struct(powerSplitRatio, infoSplitRatio, powerAmplitude, infoAmplitude);

end

