function Filter3 = ThirdOctave_Filters(Fs)

%%%%%%%%%%%%%%%
%
% Filter3 = ThirdOctave_Filters(Fs)
% 
% FUNCTION
%     This function designs IIR filters for each third octave bands with
%     the following center frequencies
%     Fc = [25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, ...
%       800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, ...
%       10000, 12500, 16000];
%
%   INPUT
%   Fs : sampling frequency in Hz
%        (NOTE: low frequencies filters may have a lower sampling frequency)
%
%
%   OUTPUT
%   Filter3: array of 29 structures which contains the filters
%            Filter3(i).FS: sampling freq. of filter for band n. i
%            Filter3(i).A : denomminator coefficients of IIR filter for band n. i
%            Filter3(i).B : numerator coefficients of IIR filter for band n. i
%            Filter3(i).Fc: center frequency of band n. i
%
% NOTE
%       this function requires OCT3DSGN function from 3rd oct. toolbox of
%       Christophe Couvreur (downloadable from MatlabCentral)
%
%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - www.genesis.fr - 2009
%%%%%%%%%%%%%%%%%%%

%%	Begin function
Fc = [25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, ...
      800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, ...
      10000, 12500, 16000];

%%	Filters with fc < 220 will be resampled 
FiltOrd=3;
Filter3 = [];

%%	Filter resampled for fc = 25 Hz.
ink=1;
q=16; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 31.5 Hz.
ink=2;
q=8; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 40 Hz.
ink=3;
q=8; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 50 Hz.
ink=4;
q=8; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 63 Hz.
ink=5;
q=4; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 80 Hz.
ink=6;
q=4; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 100 Hz.
ink=7;
q=4; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 125 Hz.
ink=8;
q=2; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  

%%	Filter resampled for fc = 160 Hz.
ink=9;
q=2; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);  


%%	Filter resampled for fc = 200 Hz.
ink=10;
q=2; 	
FsNew=100*floor(Fs/q/100);
[B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).Fc = Fc(ink);    Filter3(ink).B = B;
 

%%	Other filters should be fine
for ink=11:29
   q=1;
   FsNew=Fs/q;
   [B,A] = oct3dsgn(Fc(ink),FsNew,FiltOrd);
   Filter3(ink).FS = FsNew;
   Filter3(ink).A = A;
   Filter3(ink).B = B;
   Filter3(ink).Fc = Fc(ink);   
end   
