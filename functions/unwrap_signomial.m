function [signomial] = unwrap_signomial(signomial0, signomial1)
% Function:
%   - decomposite the product of two signomials as the sum of individual terms
%
% InputArg(s):
%   - signomial0: the first signomial
%   - signomial1: the second signomial
%
% OutputArg(s):
%   - signomial: the result signomial
%
% Comments:
%   - apply multiple times iteratively
%
% Author & Date: Yang (i@snowztail.com) - 04 Aug 19

% number of terms in the product signomials
nTerms0 = length(signomial0);
nTerms1 = length(signomial1);
% number of terms in the result signomial
nTerms = nTerms0 * nTerms1;
signomial = zeros(1, nTerms);

% unwrap product of signomials
iTerm = 0;
for iTerm0 = 1: nTerms0
    for iTerm1 = 1: nTerms1
        iTerm = iTerm + 1;
        signomial(iTerm) = signomial0(iTerm0) * signomial1(iTerm1);
    end
end
end

