clc; clear; close all;

% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% truncation order
order = 4;
% antenna resistance
resistance = 50;
% center frequency
centerFrequency = 5.18e9;
% equivalent isotropically radiated power
eirpDbm = 36; eirp = dbm2pow(eirpDbm);
% receive antenna gain
rxGainDbi = 2; rxGain = db2pow(rxGainDbi);
% path loss
pathLossDb = 58; pathLoss = db2pow(pathLossDb);
% average transmit power
txPowerDbm = -20; txPower = dbm2pow(txPowerDbm);
% bandwidth
bandwidth = 1e6;
% number of transmit antenna
nTxs = 2;
% number of subbands
nSubbands = 4;
% gap frequency
gapFrequency = bandwidth / nSubbands;
% carrier frequency
carrierFrequency = centerFrequency: gapFrequency: centerFrequency + (nSubbands - 1) * gapFrequency;
% average noise power
noisePowerDbm = -40; noisePower = dbm2pow(noisePowerDbm);
% SNR
snrDb = txPowerDbm - noisePowerDbm; snr = db2pow(snrDb);
% max number of iterations
maxIter = 1e2;
% rate constraint
minRate = 1e0;
% minimum gain ratio of the harvested current in each iteration (successive approximation)
minCurrentGainRatio = 1e-2;

clearvars eirpDbm rxGainDbi pathLossDb txPowerDbm noisePowerDbm snrDb
