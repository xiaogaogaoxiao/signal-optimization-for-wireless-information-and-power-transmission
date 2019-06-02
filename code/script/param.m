% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% truncation order
oTruncation = 4;
% antenna resistance
rAntenna = 50;
% center frequency
fCenter = 5.18e9;
% equivalent isotropically radiated power
eirpDbm = 36; eirp = dbm2pow(eirpDbm);
% receive antenna gain
gRxDbi = 2; gRx = db2pow(gRxDbi);
% path loss
plDb = 58; pl = db2pow(plDb);
% average transmit power
pTxDbm = -20; powerTx = dbm2pow(pTxDbm);
% bandwidth
b = 1e6;
% number of transmit antenna
nTx = 2;
% number of subbands
nSubband = 4;
% frequency gap
fGap = b / nSubband;
% carrier frequency
fCarrier = fCenter: fGap: fCenter + (nSubband - 1) * fGap;
% noise power
pNoiseDbm = -40; pNoise = dbm2pow(pNoiseDbm);
% SNR
snrDb = pTxDbm - pNoiseDbm;


save('..\data\param.mat');
