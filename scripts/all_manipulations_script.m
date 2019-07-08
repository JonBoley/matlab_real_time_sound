
%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% script that creates a model consisting of all manipulations

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
            if o.is_manipulation
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
% add_module(mymodel,rt_amplify(mymodel,'gain',1.000000));
% add_module(mymodel,rt_chorus(mymodel,'Delay',0.020000,'Depth1',0.010000,'Rate1',0.010000,'Depth2',0.030000,'Rate2',0.020000,'WetDryMix',0.500000));
% add_module(mymodel,rt_ci_sim(mymodel,'NrChannels',8.000000,'type','NOISE','EnvCutoff',160.000000));
% add_module(mymodel,rt_compressor(mymodel,'Threshold',-15.000000,'Ratio',5.000000,'KneeWidth',10.000000,'AttackTime',0.050000,'ReleaseTime',0.200000));
% add_module(mymodel,rt_flanger(mymodel,'Delay',0.001000,'Depth',30.000000,'Rate',0.250000,'FeedbackLevel',0.400000,'WetDryMix',0.500000));
% add_module(mymodel,rt_graficequal(mymodel,'EQOrder',2.000000,'Bandwidth','1 octave','Structure','Cascade','Gains','0,0,0,0,0,0,0,0,0,0'));
% add_module(mymodel,rt_hearingaid(mymodel,'CentreFrequencies','250,500,1000,2000,4000','AttackTime',0.050000,'ReleaseTime',0.100000,'band1_250Hz',[-20.000000,2.000000],'band2_500Hz',[-20.000000,2.000000],'band3_1000Hz',[-20.000000,2.000000],'band4_2000Hz',[-20.000000,2.000000],'band5_4000Hz',[-20.000000,2.000000],'FittingMethod','1/2 gain','Audiogram',[ 250,250.0; 500,500.0;1000,1000.0;2000,2000.0;4000,4000.0]));
% add_module(mymodel,rt_hlsimulation(mymodel,'Method','wavelet','HLSeverity','average 50'));
% add_module(mymodel,rt_ibm(mymodel,'Method','Spectral based','NumberChannel',50.000000,'SpeechThreshold',15.000000,'IdealMaskReduction',-20.000000));
% add_module(mymodel,rt_irm(mymodel,'Method','Spectral based','NumberChannel',50.000000,'SpeechThreshold',15.000000,'IdealMaskReduction',-20.000000));
% add_module(mymodel,rt_pitchshifter(mymodel,'PitchShift',8.000000,'overlap',0.300000));
% add_module(mymodel,rt_reverb(mymodel,'PreDelay',0.100000,'Diffusion',0.500000,'DecayFactor',0.500000,'WetDryMix',0.300000));
% add_module(mymodel,rt_space(mymodel,'azimuth',0.000000,'elevation',0.000000));
% add_module(mymodel,rt_specsub(mymodel,'Thres',3.000000,'alpha',2.000000,'FLOOR',0.002000,'G',0.900000));
% add_module(mymodel,rt_straightvoc(mymodel,'PitchStretch',1.000000,'FrequencyStretch',1.000000,'TimeStretch',1.000000));
% add_module(mymodel,rt_telephone(mymodel));
% add_module(mymodel,rt_wiener(mymodel,'smoothing_factor_in_apriori',0.980000,'a_priori_speech_probability',0.500000));
