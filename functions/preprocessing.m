function [Transceiver, Channel] = preprocessing(Transceiver, Channel)
% Function:
%   - reshape the channel matrix
%   - determine the beamforming phase
%
% InputArg(s):
%   - Transceiver.k2: diode k-parameters
%   - Transceiver.tx: number of transmit antennas
%   - Transceiver.rx: number of receive antennas
%   - Transceiver.weight: weight on rectennas
%   - Channel.subband: number of subbands (subcarriers)
%   - Channel.subbandAmplitude: subband amplitude of the MIMO channel
%   - Channel.subbandPhase: multipath channel phase on the subbands
%
% OutputArg(s):
%   - Channel.subbandGain: reshaped channel matrix H
%   - Transceiver.beamformPhase: the beamforming phase
%
% Comments:
%   - suboptimal phase by SVD
%
% Author & Date: Yang (i@snowztail.com) - 02 Aug 19


v2struct(Transceiver, {'fieldNames', 'k2', 'tx', 'rx', 'weight'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandAmplitude', 'subbandPhase'});

beamformPhase = zeros(subband, tx);
mimoAmplitude = zeros(subband, 1);

% subbandGain = repmat(reshape(sqrt(k2 * weight), [1 1 rx]), [subband tx]) .* subbandAmplitude .* exp(1i * subbandPhase);
subbandGain = repmat(reshape(sqrt(weight), [1 1 rx]), [subband tx]) .* subbandAmplitude .* exp(1i * subbandPhase);

for iSubband = 1: subband
    [~, lambda, v] = svd(squeeze(subbandGain(iSubband, :, :)).');
    beamformPhase(iSubband, :) = angle(v(:, 1)).';
    mimoAmplitude(iSubband) = max(diag(lambda));
end

mimoAmplitude = repmat(mimoAmplitude, [1, tx]);

Channel.subbandGain = subbandGain;
Channel.mimoAmplitude = mimoAmplitude;
Transceiver.beamformPhase = beamformPhase;

end

