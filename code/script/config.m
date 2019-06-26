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
txPowerDbm = -20; txPower = dbm2pow(txPowerDbm);
% average receive power
% rxPowerDbm = txPowerDbm + eirpDbm + rxGainDbi - pathLossDb; rxPower = dbm2pow(rxPowerDbm);
rxPowerDbm = txPowerDbm; rxPower = dbm2pow(rxPowerDbm);
% bandwidth
bandwidth = 1e6;
% number of transmit antenna
nTxs = 1;
% number of subbands
% nSubbands = [2 4 8 16]; nSubbandsRef = nSubbands(4);
nSubbands = [8];
% number of different subband cases
nCases = length(nSubbands);
% SNR
snrDb = 10: 10: 40; snrRef = snrDb(2);
% number of SNRs
nSnrs = length(snrDb);
% average noise power
noisePowerDbm = rxPowerDbm - snrDb; noisePower = dbm2pow(noisePowerDbm); noisePowerRef = noisePower(2);
% max number of iterations
maxIter = 1e1;
% rate constraint
minRate = 10: 1: 15;
% number of samples in each curve
nSamples = length(minRate);
% minimum gain ratio of the harvested current in each iteration (successive approximation)
minCurrentGainRatio = 1e-2;
% minimum gain of the harvested current in each iteration
minCurrentGain = 1e-9;
% number of channel realizations for average
nRealizations = 1e3;
% channel mode ("flat" or "selective")
channelMode = "flat";

clearvars eirpDbm rxGainDbi pathLossDb txPowerDbm noisePowerDbm snrDb
