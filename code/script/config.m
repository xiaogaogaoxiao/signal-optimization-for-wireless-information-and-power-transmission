clc; clear; close all;

% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% truncation order
order = 4;
% antenna resistance
resistance = 50;
% center frequency
centerFreq = 5.18e9;
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
gapFreq = bandwidth / nSubbands;
% carrier frequency
carrierFreq = centerFreq: gapFreq: centerFreq + (nSubbands - 1) * gapFreq;
% noise power
noisePowerDbm = -40; noisePower = dbm2pow(noisePowerDbm);
% SNR
snrDb = txPowerDbm - noisePowerDbm; snr = db2pow(snrDb);
% power splitting ratio
splitRatio = 0.5;

clearvars eirpDbm rxGainDbi pathLossDb txPowerDbm noisePowerDbm snrDb
