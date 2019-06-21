nRps = 1e5;
centerFrequency = 5.18e9;
nTxs = 1;
nSubbands = 4;

cn1 = zeros(nSubbands, nRps);
cn2 = zeros(nSubbands, nRps);

for iRp = 1: nRps
    cn1(:, iRp) = ff_cn(nSubbands, nTxs, centerFrequency);
    cn2(:, iRp) = frequency_flat_channel(nSubbands, nTxs, centerFrequency);
end

meanDiff = mean(cn1, 'all') - mean(cn2, 'all')
varDiff = var(cn1, 0, 'all') - var(cn2, 0, 'all')
