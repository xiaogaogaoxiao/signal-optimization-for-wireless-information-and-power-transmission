function [channelAmplitude] = channel_sample(nSubbands)

% FOR REFERENCE ONLY

% gap = (1.6 - 2.1) / nSubbands;
% channelAmplitude = 1.9 - (nSubbands - 1) / 2 * gap: gap: 1.9 + (nSubbands - 1) / 2 * gap;
% channelAmplitude = channelAmplitude';

if nSubbands == 2
    channelAmplitude = [2.055; 1.765];
elseif nSubbands == 4
    channelAmplitude = [2.081; 2.005; 1.863; 1.681];
elseif nSubbands == 8
    channelAmplitude = [2.083; 2.0748; 2.0358; 1.9774; 1.9023; 1.8190; 1.7245; 1.6356];
elseif nSubbands == 16
    channelAmplitude = [2.0831; 2.0833; 2.0776; 2.0665; 2.0470; 2.0219; 1.9941; 1.9617; 1.9246; 1.8801; 1.8384; 1.7940; 1.7495; 1.7023; 1.6578; 1.6106];    
end
end

