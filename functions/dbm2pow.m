function y = dbm2pow(ydBm)
% Function:
%   - converts dBm to its corresponding power value
%
% InputArg(s):
%   - ydBm: power in dBm
%
% OutputArg(s):
%   - y: power in dB
%
% Author & Date: Yang (i@snowztail.com) - 31 May 19

y = 10 .^ ((ydBm - 30) / 10);
end

