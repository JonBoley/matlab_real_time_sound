
%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% script that creates a model consisting of all measurements

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
            if o.is_measurement
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


for i=1:ccc
    eval(os{i});
    disp(os{i});
end
% 
% gui(mymodel);
% initialize(mymodel);
% run(mymodel);

return
% add_module(mymodel,rt_annoyance(mymodel,'integrationPeriod',0.400000));
% add_module(mymodel,rt_asl(mymodel,'integrationPeriod',1.000000));
% add_module(mymodel,rt_csii(mymodel,'integrationPeriod',1.000000));
% add_module(mymodel,rt_dBSPL(mymodel,'Bandwidth','1 octave'));
% add_module(mymodel,rt_haspi(mymodel,'Audiogram',[ 250,250.0; 500,500.0;1000,1000.0;2000,2000.0;4000,4000.0;6000,6000.0],'SpeechLevel',65.000000,'integrationPeriod',1.000000));
% add_module(mymodel,rt_loudness(mymodel,'integrationPeriod',0.500000));
% add_module(mymodel,rt_loudnessfastl(mymodel,'integrationPeriod',0.500000,'Visualization','slow (full Barkscale)'));
% add_module(mymodel,rt_lpc(mymodel));
% add_module(mymodel,rt_mfccs(mymodel,'FilterBank','Mel','NumCoeffs',13.000000,'WindowLength',1.000000));
% add_module(mymodel,rt_ncm(mymodel,'integrationPeriod',0.500000));
% add_module(mymodel,rt_pesq(mymodel,'gain',1.000000,'integrationPeriod',0.500000));
% add_module(mymodel,rt_pitch(mymodel,'algorithm','NCF - Normalized Correlation Function','OverlapLength',1.000000,'WindowLength',1.000000,'Range',[50.000000,400.000000],'MedianFilterLength',1.000000));
% add_module(mymodel,rt_roughness(mymodel));
% add_module(mymodel,rt_sai_ps(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'MeasureDisplay','fast'));
% add_module(mymodel,rt_sharpness(mymodel,'integrationPeriod',0.400000));
% add_module(mymodel,rt_stoi(mymodel,'integrationPeriod',1.000000));
