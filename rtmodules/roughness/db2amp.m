function amp=db2amp(level,ref)
% DB2AMP converts decibels to amplitude with optional reference level
% 
% USAGE:
%  amp=db2amp(level)
%  amp=db2amp(level,ref)
%
% The 2 argument form subtracts the ref from the level
% prior to conversion. It is useful to adopt a standard
% reference level of 80 dB to represent an amplitude
% of 1 for MATLAB sound output purposes.

if nargin < 2
  amp=10.^(level./20);
else  
  amp=10.^((level-ref)./20);
end
