%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% calibration file for no change
% use this for new calibration file

% there are three different sets, one for one octave, 2/3 octave or 1/3
% octave filters:
% 
% % case 1 octave
% calib.bandwidth='1 octave';
% calib.preferred_frequencies=[31.5 63 125 250 500 1000 2000 4000 8000 16000];
% calib.gains=zeros(size(calib.preferred_frequencies));
% 
% % case 2/3 octave
% calib.bandwidth='2/3 octave';
% calib.preferred_frequencies=[25 40 63 100 160 250 400 630 1000 1600 2500 4000 6300 10000 16000];
% calib.gains=zeros(size(calib.preferred_frequencies));

% case 1/3 octave
calib.bandwidth='1/3 octave';
calib.preferred_frequencies=[25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
calib.gains=zeros(size(calib.preferred_frequencies));

