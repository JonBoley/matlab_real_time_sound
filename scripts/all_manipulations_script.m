
% script to measure speech intellegibility
% load a speech wav file
% specify the noise and SNR
% measure intellegibility

clear all
clc
close all force

addpath(genpath('../rttools'));
addpath(genpath('../rtmodules'));
addpath(genpath('../thirdparty'));

filename='../randomwavs/BKBE0602.WAV';
l=1;

mymodel=rt_model('SampleRate',22050,'FrameLength',128,'Channels',1,'Duration',l,'OverlapAdd',0);
module_1=rt_input_file(mymodel,'filename',filename);
add_module(mymodel,module_1);
module_2=rt_annoyance(mymodel,'integrationPeriod',0.4);
add_module(mymodel,module_2);
module_2=rt_sai(mymodel,'integrationPeriod',0.4);
add_module(mymodel,module_2);

gui(mymodel);
initialize(mymodel);
run_once(mymodel);
close(mymodel);
