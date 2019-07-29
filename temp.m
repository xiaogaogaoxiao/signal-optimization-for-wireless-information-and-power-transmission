N = 2;
B = 1e6;


fr=5.18e9;
if N==1
    Delta_f=0;
    fc=fr;
else
    Delta_f=B/N;
    fc=fr-B/2+Delta_f/2;
end

period=1/fc;
unit_time=10^(-9);%period/10;
sample_frequency=1/unit_time;% this is used for the delay in the impulse response
for n=1:N
    f(n)=fc+(n-1)*Delta_f;% frequency
    lambda(n)=3e8/f(n);% wavelength
end
Os=1;%8; %oversampling factor for PAPR optimization problem
%Nsamples=20000;
if N>1
    period_sampling=1/Delta_f;
else
    period_sampling=1/fc;
end
