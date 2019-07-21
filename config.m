clc; clear; close all;
%% Transceiver
% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% antenna resistance
resistance = 50;
% number of transmit antenna
tx = 1;
% rate constraint per subband
% rateThr = 0: 0.25: 10;
rateThr = 1.5;
% number of cases for different rate constraint
nSamples = length(rateThr);
% iteration threshold for current gain
currentGainThr = 5e-8;
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
% subband = [1 2 4 8 16];
subband = 2;
% number of frequency bands as reference
subbandRef = 16;
% number of cases for different subbands
nSubbands = length(subband);
% SNR
% snrDb = [10 20 30 40];
snrDb = 20;
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
% channel fading type ("flat" or "selective")
% fadingType = "flat";
fadingType = "selective";
% frequency points for channel response plot
sampleFrequency = centerFrequency - 2.5 * bandwidth / 2: 1e4: centerFrequency + 2.5 * bandwidth / 2;
% baseband frequency
basebandFrequency = sampleFrequency - centerFrequency;
% valid frequency point index
validIndex = find(basebandFrequency >= -bandwidth / 2 & basebandFrequency <= bandwidth / 2);
%% R-E region
powerSplitRatio = 0.5;
infoSplitRatio = 1 - powerSplitRatio;
%% Pushbullet APIs for notification
apiKey = "o.yUNcIobGlYRt2DE15oosbhYHmiDXYpdP";
%% Clean up
Transceiver = v2struct(k2, k4, resistance, tx, txPower, rxPower, noisePower, noisePowerRef, snrDb, snrDbRef, nSnrs, rateThr, nSamples, currentGainThr);
Channel = v2struct(centerFrequency, bandwidth, subband, subbandRef, nSubbands, tap, fadingType, sampleFrequency, basebandFrequency, validIndex);
Solution = v2struct(powerSplitRatio, infoSplitRatio);
Push = Pushbullet(apiKey);
clearvars -except Transceiver Channel Solution Push;
