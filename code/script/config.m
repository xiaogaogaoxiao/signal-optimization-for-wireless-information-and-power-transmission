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
eirpDbm = 36;
% receive antenna gain
rxGainDbi = 2;
% path loss
pathLossDb = 58;
% average transmit power
txPowerDb = 0; txPower = db2pow(txPowerDb);
% average receive power
rxPowerDbm = txPowerDb + eirpDbm + rxGainDbi - pathLossDb; rxPower = dbm2pow(rxPowerDbm);
% bandwidth
bandwidth = 1e6;
% number of transmit antenna
nTxs = 1;
% number of subbands
nSubbands = 4;
% gap frequency
gapFrequency = bandwidth / nSubbands;
% carrier frequency
carrierFrequency = centerFrequency - (nSubbands - 1) / 2 * gapFrequency: gapFrequency: centerFrequency + (nSubbands - 1) / 2 * gapFrequency;
% SNR
snrDb = 20;
% average noise power
noisePowerDbm = rxPowerDbm - snrDb; noisePower = dbm2pow(noisePowerDbm);
% max number of iterations
maxIter = 1e2;
% rate constraint
minRate = 1;
% minimum gain ratio of the harvested current in each iteration (successive approximation)
minCurrentGainRatio = 1e-3;
% minimum gain of the harvested current in each iteration
minCurrentGain = 1e-8;

clearvars eirpDbm rxGainDbi pathLossDb txPowerDbm noisePowerDbm snrDb
