load('param.mat');
hChannel = zeros(nTx, nSubband);

for iTx = 1: nTx
    % tapped-delay line with HIPERLAN/2-B model
    [dTap, gTap] = hyperlan2B();
    for iSubband = 1: nSubband
        % channel gain
        hChannel(iTx, iSubband) = sum(gTap .* exp(-1i * 2 * pi * fCarrier(iSubband) * dTap));
    end
end
