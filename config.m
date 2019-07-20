clc; clear; close all;
%% Transceiver
% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% antenna resistance
resistance = 50;
% number of transmit antenna
tx = [1];
% rate constraint per subband
rateConstraint = 0: 0.25: 10;
% number of cases for different rate constraint
nSamples = length(rateConstraint);
% iteration threshold for current gain
currentGainThr = 5e-8;

Transceiver = v2struct(k2, k4, resistance, tx, rateConstraint, nSamples, currentGainThr);
%% Channel
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
% center frequency
centerFrequency = 5.18e9;
% bandwidth
bandwidth = 1e6;
% number of frequency bands
subband = [1 2 4 8 16];
% number of frequency bands as reference
subbandRef = 16;
% number of cases for different subbands
nSubbands = length(subband);
% SNR
snrDb = [10 20 30 40];
% SNR as reference
snrDbRef = 20;
% number of cases for different SNRs
nSnrs = length(snrDb);
% average noise power
noisePowerDbm = rxPowerDbm - snrDb; noisePower = dbm2pow(noisePowerDbm);
% average noise power as reference
noisePowerRefDbm = rxPowerDbm - snrDbRef; noisePowerRef = dbm2pow(noisePowerRefDbm);
% number of taps in the tapped-delay line model
tap = 18;
% channel mode ("flat" or "selective")
% mode = "flat";
mode = "selective";
% frequency points for channel response plot
sampleFrequency = centerFrequency - 2.5 * bandwidth / 2: 1e4: centerFrequency + 2.5 * bandwidth / 2;

Channel = v2struct(txPower, rxPower, noisePower, noisePowerRef, centerFrequency, bandwidth, subband, subbandRef, nSubbands, snrDb, snrDbRef, nSnrs, tap, mode, sampleFrequency);
%% Pushbullet APIs for notification
apiKey = "o.yUNcIobGlYRt2DE15oosbhYHmiDXYpdP";

Push = Pushbullet(apiKey);
%% Clean up
clearvars -except Transceiver Channel Push;
