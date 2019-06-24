%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% run a claibration gui that helps to create the calibration file

clear all
clc
close all force
addpath(genpath('./rttools'));
addpath(genpath('./rtmodules'));
addpath(genpath('./thirdparty'));

bw='1 octave';
% bw='2/3 octave';
% bw='1/3 octave';

switch bw
    case '1 octave'
        frf=10;
        % case 1 octave
        calib.bandwidth='1 octave';
        calib.preferred_frequencies=[31.5 63 125 250 500 1000 2000 4000 8000 16000];
        calib.gains=zeros(size(calib.preferred_frequencies));
        
    case '2/3 octave'
        frf=15;
        % case 2/3 octave
        calib.bandwidth='2/3 octave';
        calib.preferred_frequencies=[25 40 63 100 160 250 400 630 1000 1600 2500 4000 6300 10000 16000];
        calib.gains=zeros(size(calib.preferred_frequencies));
        
    case '1/3 octave'
        frf=30;
        % case 1/3 octave
        calib.bandwidth='1/3 octave';
        calib.preferred_frequencies=[25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
        calib.gains=zeros(size(calib.preferred_frequencies));
end

pp=parameterbag('calibration');
for i=1:frf
    s=sprintf('%4.1f Hz',calib.preferred_frequencies(i));
    p=param_number_with_button(s,0,'button_callback_function','freq_callback_fct(p)','button_text','play sound');
    add(pp,p)
end
add(pp,param_number('AssumedLoudnessdB',80));
add(pp,param_generic('filename','calib_file.m'));


gui(pp);



function freq_callback_fct(obj)

end



