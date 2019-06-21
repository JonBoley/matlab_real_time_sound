%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% calibration file for AKG K271 Headphones
% values recorded by SBleeck 20.6.2019
% 
% % case 1/3 octave
% calib.bandwidth='1/3 octave';
% calib.preferred_frequencies=[25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
% calib.gains=zeros(size(calib.preferred_frequencies));

% % case 2/3 octave
% calib.bandwidth='2/3 octave';
% calib.preferred_frequencies=[25 40 63 100 160 250 400 630 1000 1600 2500 4000 6300 10000 16000];
% calib.gains=[ 20,  17,  3,  2,  6,  -4, -19, -21, -20,  -21,  -17,  -11,   -5,     7,    9];


% y2=resample(calib.gains,30,15)

% case 1/3 octave
calib.bandwidth='1/3 octave';
calib.preferred_frequencies=[25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
calib.gains=[ ...
   20.0103   22.7615   17.0088    8.7171    3.0016    0.9954    2.0010    4.6002    6.0031    3.2226   -4.0021 ...
  -12.6552  -19.0098  -21.4340  -21.0109  -20.0365  -20.0103  -20.7478  -21.0109  -19.7619  -17.0088  -13.7627 ...
  -11.0057   -8.5859   -5.0026    0.6796    7.0036   10.5235    9.0047    4.1054...
  ];



