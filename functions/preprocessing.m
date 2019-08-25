function [Transceiver, Channel] = preprocessing(Transceiver, Channel)
% Function:
%   - reshape the channel matrix
%   - determine the beamforming phase
%
% InputArg(s):
%   - Transceiver.k2: diode k-parameters
%   - Transceiver.tx: number of transmit antennas
%   - Channel.subband: number of subbands (subcarriers)
%   - Channel.subbandGain: complex gain on each subband
%
% OutputArg(s):
%   - Channel.mimoAmplitude: maximum eigenvalue of channel matrix on each
%   subband, repeated for all transmit antennas
%   - Transceiver.beamformPhase: the beamforming phase
%
% Comments:
%   - suboptimal phase by SVD
%
% Author & Date: Yang (i@snowztail.com) - 02 Aug 19


v2struct(Transceiver, {'fieldNames', 'k2', 'tx'});
v2struct(Channel, {'fieldNames', 'subband', 'subbandGain'});

beamformPhase = zeros(subband, tx);
mimoAmplitude = zeros(subband, 1);

for iSubband = 1: subband
    [~, sigma, v] = svd(squeeze(subbandGain(iSubband, :, :)).');
    beamformPhase(iSubband, :) = angle(v(:, 1)).';
    mimoAmplitude(iSubband) = max(diag(sigma));
end

mimoAmplitude = repmat(mimoAmplitude, [1, tx]);

Channel.mimoAmplitude = mimoAmplitude;
Transceiver.beamformPhase = beamformPhase;

end
