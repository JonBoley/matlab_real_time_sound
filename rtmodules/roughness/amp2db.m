function db=amp2db(level,ref)
%AMP2DB converts amplitude to decibels with optional reference level
% USAGE:
%  db=amp2db(level)
%  db=amp2db(level,ref)
%
% The 2 argument form adds the reference to the dB level
% after conversion. It is useful to adopt a standard
% reference level of 80 dB to represent an amplitude
% of 1 for MATLAB sound output purposes.

if nargin < 2
  db=20.*log10(level);
else
  db=ref+20.*log10(level);
end  
 
