
% script to run a simple hearing aid with real time controls
clear all
clc
close all force

addpath(genpath('../rttools'));
addpath(genpath('../rtmodules'));

mymodel=rt_model('SampleRate',22050,'FrameLength',128,'Channels',1,'Duration',Inf,'OverlapAdd',0);
module_1=rt_input_oscillator(mymodel,'SignalType','sine','Frequency',1000,'Amplitude',70);
add_module(mymodel,module_1);
module_3=rt_output_speaker(mymodel,'Calibrate',1,'system_output_type','Default','CalibrationFile','AKG_K271_MkII_1_3_octave.m');
add_module(mymodel,module_3);

gui(module_1.p);  % show thcce input parameters

initialize(mymodel);
run_once(mymodel);
close(mymodel);
