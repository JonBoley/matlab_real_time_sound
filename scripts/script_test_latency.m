% script to test the latency in a number of cases
% concept is to play a short noise over the output and record the incoming
% sound at the input. They must of course be acoustically coupled to get a
% result


clear all
% clc
close all force


sr=22050;
frame_length=256;

ADR = audioDeviceReader;
indevices=getAudioDevices(ADR);
ADW = audioDeviceWriter;
outdevices=getAudioDevices(ADW);
disp('choose input devices:');
for i=1:length(indevices)
    fprintf('(%d) %s\n',i,indevices{i});
end
% inpnr=input('choose a number: ');
inpnr=1;
fprintf('\n\n');
disp('choose output devices:');
for i=1:length(outdevices)
    fprintf('(%d) %s\n',i,outdevices{i});
end
% outpnr=input('choose a number: ');
outpnr=1;
system_output_type=outdevices{inpnr};
system_input_type=indevices{outpnr};

fprintf('performing latency measurement with the following devices:\n');
fprintf('output: %s\n',system_output_type);
fprintf('input: %s\n',system_input_type);
fprintf('\n');
fprintf('SampleRate: %d\n',sr);
fprintf('FrameLength: %d\n',frame_length);


addpath(genpath('../rttools'));
addpath(genpath('../rtmodules'));

mymodel=rt_model('SampleRate',sr,'FrameLength',frame_length,'Channels',1,'Duration',1,'OverlapAdd',0);
% module_1=rt_input_oscillator(mymodel,'SignalType','sine','Frequency',1000,'Amplitude',80);
% module_1=rt_input_oscillator(mymodel,'SignalType','noise','NoiseColor','white','Amplitude',50);
% add_module(mymodel,module_1);

module_1b=rt_amplify(mymodel);
add_module(mymodel,module_1b);


module_2=rt_output_speaker(mymodel,'Calibrate',0,'system_output_type',system_output_type,'CalibrationFile','AKG_K271_MkII_1_3_octave.m');
% choices={'first record then play';'first play then record'};
% module_2=rt_input_output(mymodel,'Direction',choices{2});
add_module(mymodel,module_2);

module_3=rt_input_microphone(mymodel,'system_input_type',system_input_type,'Calibrate',0,'CalibrationFile','Apple_Display_Audio_Mic.m');
add_module(mymodel,module_3);
module_4=rt_measure_latency(mymodel);
add_module(mymodel,module_4);

initialize(mymodel);
run_once(mymodel);
close(mymodel);

fprintf('%d dropouts\n',mymodel.last_dropout);

