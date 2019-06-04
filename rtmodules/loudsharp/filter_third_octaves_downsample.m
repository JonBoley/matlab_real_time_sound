function [Ptotal, P, F] = filter_third_octaves_downsample(x, Pref, Fs, Fmin, Fmax, N)

% Calls the octave design function for each of the octave bands
% x is the file (Input length must be a multiple of 2^8)
% Pref is the reference level for calculating decibels
% Fmin is the minimum frequency
% Fmax is the maximum frequency (must be at least 2500 Hz)
% Fs is the sampling frequency
% N is the filter order

%****************************************************************************************
% PART 1
%fprintf('PART 1: Calculates the frequency midbands(ff), corresponding nominal frequecies(F) and indices(i)\n')
%****************************************************************************************

[ff, F, j] = midbands(Fmin, Fmax, Fs);

%****************************************************************************************
% PART 2A
%fprintf('PART 2A: Designs and implements the filters, computing the RMS levels in each 1/3-oct. band\n')
%****************************************************************************************

P = zeros(1,length(j));
k = find(j==7); % Determines where downsampling will commence (5000 Hz and below)
m = length(x);

% For frequencies of 6300 Hz or higher, direct implementation of filters.
for i = length(j):-1:k+1;
    [B,A] = filter_design2(ff(i),Fs,N);
    if i==k+3; % Upper 1/3-oct. band in last octave. 
        Bu=B;
        Au=A;
    end
    if i==k+2; % Center 1/3-oct. band in last octave. 
        Bc=B;
        Ac=A;
    end
    if i==k+1; % Lower 1/3-oct. band in last octave. 
        Bl=B;
        Al=A;
    end
    y = filter(B,A,x);
    P(i) = 20*log10(sqrt(sum(y.^2)/m)); % Convert to decibels.  
end

% 5000 Hz or lower, multirate filter implementation.
try 
    for i = k:-3:1;
          % Design anti-aliasing filter (IIR Filter)
        Wn = 0.4;
        [C,D] = cheby1(2,0.1,Wn);
          % Filter
        x = filter(C,D,x);
          % Downsample
        x = downsample(x,2,1); % Offset by one to eliminate end effects
        Fs = Fs/2;
        m = length(x);
          % Performs the filtering
        y = filter(Bu,Au,x);
        P(i) = 20*log10(sqrt(sum(y.^2)/m));
        y = filter(Bc,Ac,x);
        P(i-1) = 20*log10(sqrt(sum(y.^2)/m));
        y = filter(Bl,Al,x);
        P(i-2) = 20*log10(sqrt(sum(y.^2)/m));
    end
catch
    error = lasterr
    P = P(1:length(j));
end

%*****************************************************************************************
% PART 3
%fprintf('PART 3: Calibrates the readings\n')
%*****************************************************************************************

P = P + Pref; 				% Reference level for dB scale, from calibration run.

%*****************************************************************************************
% PART 4
%fprintf('PART 5: Generates a plot of the powers within each frequency band\n')
%*****************************************************************************************

% figure(203)
% bar(P);
% axis([0 (length(F)+1) (-10) (max(P)+1)]) 
% set(gca,'XTick',[1:3:length(P)]); 		 
% set(gca,'XTickLabel',F(1:3:length(F))); % Labels frequency axis on third octaves.
% xlabel('Frequency band [Hz]'); ylabel('Powers [dB]');
% title('One-third-octave spectrum')

Plog = 10.^(P./10);
Ptotal = sum(Plog);
Ptotal = 10*log10(Ptotal);

% figure(203)
% text(1,-5,'Ptotal [dB] =')
% text(5,-5,num2str(Ptotal))