clc; clear; close all;

% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
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
rxPowerDbm = eirpDbm + rxGainDbi - pathLossDb; rxPower = dbm2pow(rxPowerDbm);
% bandwidth
bandwidth = 1e6;
% number of transmit antenna
nTxs = 1;
% number of subbands
nSubbands = [2 4 8 16];
nSubbandsRef = 2;
% number of frequency samples over unit bandwidth
nFrequencySamples = 1e2;
% number of different subband cases
nSubbandCases = length(nSubbands);
% SNR
snrDb = [10 20 30 40];
snrRefDb = 20;
% number of SNRs
nSnrCases = length(snrDb);
% average noise power
noisePowerDbm = rxPowerDbm - snrDb; noisePower = dbm2pow(noisePowerDbm);
noisePowerRefDbm = rxPowerDbm - snrRefDb; noisePowerRef = dbm2pow(noisePowerRefDbm);
% max number of iterations for convergence
maxIter = 1e1;
% rate constraint per subband
minSubbandRate = 0: 0.5: 10;
% number of samples in each curve
nRateSamples = length(minSubbandRate);
% minimum gain of the harvested current in each iteration
minCurrentGain = 5e-8;
% channel mode ("flat" or "selective")
% channelMode = "flat";
channelMode = "selective";

clearvars eirpDbm rxGainDbi pathLossDb txPowerDbm rxPowerDbm noisePowerDbm noisePowerRefDbm snrDb snrRefDb
