%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% run a claibration gui that helps to create the calibration file

clear all
clc
close all force
addpath(genpath('../rttools'));
addpath(genpath('../rtmodules'));
addpath(genpath('../thirdparty'));


disp('running input calibration');
disp('principle: specify filename which hardware you are using (which microphone, etc');
disp('then you will need to play sounds that are exaclty 70 dB loud');
disp('and record how loud they are measured at.');
disp('You can of course use an output devicem calibrated with the realtime sound platform');
disp('your job is to create pure tones of various frequencies of exaclty 70 dB');
disp('at the point of the microphone.');
disp('You will have to use a sound level meter to make sure that the sounds are exaclty 70 dB)');
disp('When you play a sound of one frequency at 70 dB, press the respective button in the gui');
disp('and wait for a few seconds. The computer is creating an averaged measument in this time.');
disp('Don''t change the numbers by hand!');
disp('The sound level meter should have the following settings:');
disp('linear measure (dBZ)');
disp('slow averaging');
disp('to start, you will see a  graphical user interface with the required frequencies');
disp('Put in the measured number in the correct field in the graphical user interface');
disp('and press close when you are finished');

calib_level=70;  % this is the loudness of the tone that I play
filename=get_new_filename('calib_in_file','m');
bw='1 octave';
% bw='2/3 octave';
% bw='1/3 octave';
ADR = audioDeviceReader;
devices=getAudioDevices(ADR);
device=devices{5};
fprintf('performing calibration with input device %s',device);
calib=run_input_calibration(bw,filename,calib_level,device);





