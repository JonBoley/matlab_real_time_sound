
%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% script that creates a model consisting of all visualizations

redo=1;
if redo
    clear all
    close all force
    clc
    addpath(genpath('../rttools'));
    addpath(genpath('../rtmodules'));
    addpath(genpath('./thirdparty'));
    ccc=0;
    wdir='../rtmodules';
    base_d=cd(wdir);
    allfiles=dir();
    ss=[];obj=[];
    for i=1:length(allfiles)
        ll=allfiles(i).name;
        %     ll
        if contains(ll,'.m') && ~contains(ll,'~')
            %         i
            name=ll(1:end-2);
            %         fprintf('%d: found %s... ',i,name);
            str=sprintf('o=%s(obj);',name);
            eval(str);
            if o.is_visualization
                ccc=ccc+1;
                ss{ccc}=get_as_script_string(o);
                os{ccc}=sprintf('add_module(mymodel,%s);',ss{ccc});
            end
        end
    end
    cd(base_d);
    
    
end

% result:
sr=16000;
frame_length=128;
mymodel=rt_model('SampleRate',sr,'FrameLength',frame_length,'Channels',1,'Duration',1,'OverlapAdd',0,'PlotWidth',1);
add_module(mymodel,rt_input_file_random(mymodel,'foldername','../randomwavs','MaxFileLeveldB',100.000000));


for i=1
    eval(os{i});
    disp(os{i});
end

gui(mymodel);
initialize(mymodel);
run(mymodel);

return
% 
% add_module(mymodel,rt_bmm(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'autoscale',0,'zoom',1.000000));
% add_module(mymodel,rt_nap(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'zoom',1.000000));
% add_module(mymodel,rt_sai(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'zoom',1.000000));
% add_module(mymodel,rt_spectrum(mymodel,'WindowLength',30.000000,'Overlap',20.000000,'NumberFFTbins','256','WindowFunction','blackmanharris','zoom',1.000000));
% add_module(mymodel,rt_spectrum_lpc(mymodel,'WindowLength',30.000000,'Overlap',20.000000,'NumberFFTbins','256','WindowFunction','blackmanharris','zoom',1.000000));
% add_module(mymodel,rt_strobes(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'zoom',1.000000));
% add_module(mymodel,rt_vad(mymodel,'zoom',1.000000,'FFTLength',256.000000,'Window','Hann','SidelobeAttenuation',60.000000,'SilenceToSpeechProbability',0.200000,'SpeechToSilenceProbability',0.100000));
% add_module(mymodel,rt_vtl(mymodel));
% add_module(mymodel,rt_waveform(mymodel,'zoom',1.000000));

