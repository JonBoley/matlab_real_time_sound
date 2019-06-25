%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% run a claibration gui that helps to create the calibration file

clear all
clc
close all force
addpath(genpath('../../rttools'));
addpath(genpath('../../rtmodules'));
addpath(genpath('../../thirdparty'));


disp('running output calibration');
disp('principle: specify filename which hardware you are using (speaker, computer, headphone, etc');
disp('then the script will generate a series of tones at specified frequencies that are exactly 70 dB loud');
disp('your job is to measure the receied loudness using a calibrated device (sound level meter)');
disp('with the following settings:');
disp('linear measure (dBZ)');
disp('slow averaging');
disp('== LLS(SPL)');
disp('to start, you will see a  graphical user interface that allows playing of pure tones at all');
disp('required frequencies');
disp('finally, put the measured number in the correct field in the graphical user interface');

calib_level=70;  % this is the loudness of the tone that I play
filename=get_new_filename('calib_out_file','m');
% bw='1 octave';
% bw='2/3 octave';
bw='1/3 octave';
calib=run_output_calibration(bw,filename,calib_level);





