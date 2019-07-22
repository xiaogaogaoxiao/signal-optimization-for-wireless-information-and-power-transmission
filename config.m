clc; clear; close all;
%% Channel
% center frequency
centerFrequency = 5.18e9;
% bandwidth
bandwidth = 1e6;
% number of frequency bands
subband = 2;
% number of taps in the tapped-delay line model
tap = 18;
% channel fading type ("flat" or "selective")
% fadingType = "flat";
fadingType = "selective";
% gap frequency
gapFrequency = bandwidth / subband;
% sample frequency
sampleFrequency = centerFrequency - 0.5 * (bandwidth - gapFrequency): gapFrequency: centerFrequency + 0.5 * (bandwidth - gapFrequency);

Channel = v2struct(centerFrequency, bandwidth, subband, tap, fadingType, sampleFrequency);
%% Transceiver
% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% antenna resistance
resistance = 50;
% number of transmit antenna
tx = 1;
% average transmit power
txPowerDbm = -20; txPower = dbm2pow(txPowerDbm);
% average receive power
rxPowerDbm = -20; rxPower = dbm2pow(rxPowerDbm);
% SNR
snrDb = 20;
% average noise power
noisePowerDbm = rxPowerDbm - snrDb; noisePower = dbm2pow(noisePowerDbm);
% iteration threshold for current gain
currentGainThr = 5e-8;

Transceiver = v2struct(k2, k4, resistance, tx, txPower, rxPower, snrDb, noisePower, currentGainThr);
%% Response plot
% frequency points for channel response plot
sampleFrequency = centerFrequency - 2.5 * bandwidth / 2: 1e4: centerFrequency + 2.5 * bandwidth / 2;
% baseband frequency
basebandFrequency = sampleFrequency - centerFrequency;
% valid frequency point index
validIndex = find(basebandFrequency >= -bandwidth / 2 & basebandFrequency <= bandwidth / 2);

Response = v2struct(centerFrequency, bandwidth, subband, tap, fadingType, sampleFrequency, basebandFrequency, validIndex);
%% Variables
% rate constraint per subband
rateThr = 10: -0.5: 0;
% number of samples
nSamples = length(rateThr);
% different subband cases
subband = [1 2 4 8 16];
% number of subband cases
nSubbandCases = length(subband);
% gap frequency
gapFrequency = bandwidth ./ subband;
% sample frequency
sampleFrequency = cell(nSubbandCases, 1);
for iCase = 1: nSubbandCases
    sampleFrequency{iCase} = centerFrequency - 0.5 * (bandwidth - gapFrequency(iCase)): gapFrequency(iCase): centerFrequency + 0.5 * (bandwidth - gapFrequency(iCase));
end
% different SNR cases
snrDb = [10 20 30 40];
% number of SNR cases
nSnrCases = length(snrDb);
% average noise power
noisePowerDbm = rxPowerDbm - snrDb; noisePower = dbm2pow(noisePowerDbm);

Variable = v2struct(rateThr, nSamples, subband, nSubbandCases, gapFrequency, sampleFrequency, snrDb, nSnrCases, noisePower);
%% Pushbullet APIs
apiKey = "o.yUNcIobGlYRt2DE15oosbhYHmiDXYpdP";

Push = Pushbullet(apiKey);
%% Clean up
clearvars -except Transceiver Channel Response Variable Push;
