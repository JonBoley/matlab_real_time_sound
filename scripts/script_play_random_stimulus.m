

clear all
clc
close all force
addpath(genpath('../rttools'));
addpath(genpath('../rtmodules'));
addpath(genpath('../thirdparty'));
mymodel=rt_model('SampleRate',22050,'FrameLength',256,'Channels',1,'Duration',Inf,'OverlapAdd',0,'PlotWidth',1.000000);
module_1=rt_input_file_random(mymodel,'foldername','../randomwavs','MaxFileLeveldB',100.000000);
add_module(mymodel,module_1);
% module_2=rt_waveform(mymodel,'zoom',1.000000);
% add_module(mymodel,module_2);
module_3=rt_output_speaker(mymodel,'Calibrate',1,'system_output_type','Default','CalibrationFile','AKG_K271_MkII_1_3_octave.m');
add_module(mymodel,module_3);

gui(mymodel);
initialize(mymodel);
run_once(mymodel);
close(mymodel);
