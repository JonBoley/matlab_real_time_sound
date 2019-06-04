%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  A-weighting Filter                  %
%              with MATLAB Implementation              %
%                                                      %
% Author: M.Sc. Eng. Hristo Zhivomirov        06/01/14 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xA = filterA(x, fs)
% function: xA = filterA(x, fs)
% x - original signal in the time domain
% fs - sampling frequency, Hz
% xA - filtered signal in the time domain
% Note: The A-weighting filter's coefficients 
% are acccording to IEC 61672-1:2002 standard 
% determine the signal length
xlen = length(x);
% number of unique points
NumUniquePts = ceil((xlen+1)/2);
% FFT
X = fft(x);
% fft is symmetric, throw away the second half
X = X(1:NumUniquePts);
% frequency vector with NumUniquePts points
f = (0:NumUniquePts-1)*fs/xlen;
% A-weighting filter coefficients
c1 = 12194.217^2;
c2 = 20.598997^2;
c3 = 107.65265^2;
c4 = 737.86223^2;
% evaluate the A-weighting filter in the frequency domain
f = f.^2;
num = c1*(f.^2);
den = (f+c2) .* sqrt((f+c3).*(f+c4)) .* (f+c1);
A = 1.2589*num./den;
% filtering in the frequency domain
XA = X(:).*A(:);
% reconstruct the whole spectrum
if rem(xlen, 2)                     % odd xlen excludes the Nyquist point
    XA = [XA; conj(XA(end:-1:2))];
else                                % even xlen includes the Nyquist point
    XA = [XA; conj(XA(end-1:-1:2))];
end
% IFFT
xA = real(ifft(XA));
    
% represent the filtered signal in the form of the original one
xA = reshape(xA, size(x));
end