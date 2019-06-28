
% script to run a simple hearing aid with real time controls
clear all
clc
close all force

addpath(genpath('../rttools'));
addpath(genpath('../rtmodules'));

mymodel=rt_model('SampleRate',16000,'FrameLength',128,'Channels',1,'Duration',Inf,'OverlapAdd',0);
module_1=rt_input_microphone(mymodel,'system_input_type','Default','Calibrate',1,'CalibrationFile','Apple_Display_Audio_Mic.m');
add_module(mymodel,module_1);
module_2=rt_hearingaid(mymodel,'CentreFrequencies','250,500,1000,2000,4000','AttackTime',0.050000,'ReleaseTime',0.100000,'band1_250Hz',[-20.000000,1.000000],'band2_500Hz',[-20.000000,1.333333],'band3_1000Hz',[-20.000000,2.000000],'band4_2000Hz',[-20.000000,4.000000],'band5_4000Hz',[-20.000000,100.000000],'FittingMethod','1/2 gain','Audiogram',[ 250,0.0; 500,10.0;1000,20.0;2000,30.0;4000,40.0]);
add_module(mymodel,module_2);
module_3=rt_output_speaker(mymodel,'Calibrate',1,'system_output_type','Default','CalibrationFile','AKG_K271_MkII_1_3_octave.m');
add_module(mymodel,module_3);

% gui(module_1.p);  % show the input parameters
gui(module_2.p); % show the hearing aid parameter for realtime tuning
% gui(module_3.p);% show the output parameters

initialize(mymodel);
run_once(mymodel);
close(mymodel);
