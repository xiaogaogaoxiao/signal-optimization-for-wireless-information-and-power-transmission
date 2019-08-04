function [monomial] = unwrap_signomial(monomial0, monomial1)
% Function:
%   - decomposite the product of two signomials as the sum of individual terms
%
% InputArg(s):
%   - monomial0: the first signomial
%   - monomial1: the second signomial
%
% OutputArg(s):
%   - monomial: the result signomial
%
% Comments:
%   - apply multiple times iteratively
%
% Author & Date: Yang (i@snowztail.com) - 04 Aug 19

% number of terms in the product signomials
nTerms0 = length(monomial0);
nTerms1 = length(monomial1);
% number of terms in the result signomial
nTerms = nTerms0 * nTerms1;
monomial = zeros(1, nTerms);

% unwrap product of signomials
iTerm = 0;
for iTerm0 = 1: nTerms0
    for iTerm1 = 1: nTerms1
        iTerm = iTerm + 1;
        monomial(iTerm) = monomial0(iTerm0) * monomial1(iTerm1);
    end
end
end

