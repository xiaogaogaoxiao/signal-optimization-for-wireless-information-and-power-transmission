clear; close all;
load('parameter.mat');

temp = waveform(nSubband, nTx, fCarrier, k2, k4, rho, rAntenna, pNoise);
