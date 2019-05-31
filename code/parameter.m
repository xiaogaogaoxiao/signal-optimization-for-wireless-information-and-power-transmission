clear; close all;
% diode k-parameter
k2 = 0.0034; k4 = 0.3829;
% truncation order
n0 = 4;
% antenna resistance
R_ant = 50;
% center frequency
f0 = 5.18e9;
% equivalent isotropically radiated power
EIRP_dbm = 36; EIRP = dbm2pow(EIRP_dbm);
% receive antenna gain
G_rx_dbi = 2; G_rx = db2pow(G_rx_dbi);
% path loss
PL_db = 58; PL = db2pow(PL_db);
% average transmit power
P_tx_dbm = -20; P_tx = dbm2pow(P_tx_dbm);
