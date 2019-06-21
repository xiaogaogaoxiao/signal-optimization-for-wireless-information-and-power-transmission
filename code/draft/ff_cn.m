function [channelAmplitude] = ff_cn(nSubbands, nTxs, centerFrequency)

f=centerFrequency;
unit_time=1e-9;
M=nTxs;
N=nSubbands;

power_dB=[-2.6,-3,-3.5,-3.9,0,-1.3,-2.6,-3.9,-3.4,-5.6,-7.7,-9.9,-12.1,-14.3,-15.4,-18.4,-20.7,-24.6]; %power_dB=0;%ones(1,1);%kron(ones(1,1000),power_dB);
power_dB=10*log10(10.^(power_dB/10)/sum(10.^(power_dB/10)));
sum(10.^(power_dB/10));
L=length(power_dB);% let us assume the same impulse response length for all users for simplicity 
power_linear=10.^(power_dB/20); %L=1;
for m = 1:1
    for u = 1:1
        channel_gain{u} = 1/sqrt(2)*complex(randn(M(m),L),randn(M(m),L)).*(ones(M(m),1)*power_linear); % assume iid channel across space
        IR{1}{u}(1:M(m),1:L) = channel_gain{u}(1:M(m),1:L);%complex gain
        IR{2}{u}(1,1:L)=[0,10,20,30,50,80,110,140,180,230,280,330,380,430,490,560,640,730];% (ns) % assume same delay for all users
%         channel{idx}=IR;
    end
end % if 0
for n=1:N
    for u = 1:1
        for m = 1:M
            eq=0;
            for l=1:L
                eq=eq+IR{1}{u}(m,l)*exp(-1i*2*pi*f*IR{2}{u}(1,l)*unit_time);
            end
            h(m,n) = eq;
        end
    end
end
channelAmplitude = abs(h);

end
