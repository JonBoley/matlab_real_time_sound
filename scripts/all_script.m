
%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% a simple list of all default inits



% script that creates and then displays the default initialization code for
% each module in rtmodules and rttools

redo=0;
if redo
    clear all
    close all force
    clc
    addpath(genpath('../rttools'));
    addpath(genpath('../rtmodules'));
    % addpath(genpath('./thirdparty'));
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
            ss{i}=get_as_script_string(o);
            ccc=ccc+1;
            os{ccc}=sprintf('add_module(mymodel,%s);',ss{i});
        end
    end
    cd(base_d);
    
    
    wdir='../rttools';
    base_d=cd(wdir);
    allfiles=dir();
    obj=[];ss2=[];
    for i=1:length(allfiles)
        ll=allfiles(i).name;
        %     ll
        if contains(ll,'.m') && ~contains(ll,'~')
            %         i
            name=ll(1:end-2);
            %         fprintf('%d: found %s... ',i,name);
            str=sprintf('o=%s(obj);',name);
            try
                eval(str);
                ss2{i}=get_as_script_string(o);
                ccc=ccc+1;
                os{ccc}=sprintf('add_module(mymodel,%s);',ss2{i});
            end
        end
    end
    cd(base_d);
    
end


%
% for i=1:ccc
% %     try
%        eval(os{i});
% %     catch
%         disp(os{i});
% %     end
% end



% result:
sr=16000;
frame_length=128;
mymodel=rt_model('SampleRate',sr,'FrameLength',frame_length,'Channels',1,'Duration',1,'OverlapAdd',0,'PlotWidth',1);
add_module(mymodel,rt_amplify(mymodel,'gain',1.000000));
add_module(mymodel,rt_annoyance(mymodel,'integrationPeriod',0.400000));
add_module(mymodel,rt_asl(mymodel,'integrationPeriod',1.000000));
add_module(mymodel,rt_bmm(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'autoscale',0,'zoom',1.000000));
add_module(mymodel,rt_chorus(mymodel,'Delay',0.020000,'Depth1',0.010000,'Rate1',0.010000,'Depth2',0.030000,'Rate2',0.020000,'WetDryMix',0.500000));
add_module(mymodel,rt_ci_sim(mymodel,'NrChannels',8.000000,'type','NOISE','EnvCutoff',160.000000));
add_module(mymodel,rt_compressor(mymodel,'Threshold',-15.000000,'Ratio',5.000000,'KneeWidth',10.000000,'AttackTime',0.050000,'ReleaseTime',0.200000));
add_module(mymodel,rt_csii(mymodel,'integrationPeriod',1.000000));
add_module(mymodel,rt_dBSPL(mymodel,'Bandwidth','1 octave'));
add_module(mymodel,rt_flanger(mymodel,'Delay',0.001000,'Depth',30.000000,'Rate',0.250000,'FeedbackLevel',0.400000,'WetDryMix',0.500000));
add_module(mymodel,rt_graficequal(mymodel,'EQOrder',2.000000,'Bandwidth','1 octave','Structure','Cascade','Gains','0,0,0,0,0,0,0,0,0,0'));
add_module(mymodel,rt_haspi(mymodel,'Audiogram',[ 250,250.0; 500,500.0;1000,1000.0;2000,2000.0;4000,4000.0;6000,6000.0],'SpeechLevel',65.000000,'integrationPeriod',1.000000));
add_module(mymodel,rt_hearingaid(mymodel,'CentreFrequencies','250,500,1000,2000,4000','AttackTime',0.050000,'ReleaseTime',0.100000,'band1_250Hz',[-20.000000,2.000000],'band2_500Hz',[-20.000000,2.000000],'band3_1000Hz',[-20.000000,2.000000],'band4_2000Hz',[-20.000000,2.000000],'band5_4000Hz',[-20.000000,2.000000],'FittingMethod','1/2 gain','Audiogram',[ 250,250.0; 500,500.0;1000,1000.0;2000,2000.0;4000,4000.0]));
add_module(mymodel,rt_hlsimulation(mymodel,'Method','wavelet','HLSeverity','average 50'));
add_module(mymodel,rt_ibm(mymodel,'Method','Spectral based','NumberChannel',50.000000,'SpeechThreshold',15.000000,'IdealMaskReduction',-20.000000));
add_module(mymodel,rt_irm(mymodel,'Method','Spectral based','NumberChannel',50.000000,'SpeechThreshold',15.000000,'IdealMaskReduction',-20.000000));
add_module(mymodel,rt_loudness(mymodel,'integrationPeriod',0.500000));
add_module(mymodel,rt_loudnessfastl(mymodel,'integrationPeriod',0.500000,'Visualization','slow (full Barkscale)'));
add_module(mymodel,rt_lpc(mymodel));
add_module(mymodel,rt_mfccs(mymodel,'FilterBank','Mel','NumCoeffs',13.000000,'WindowLength',1.000000));
add_module(mymodel,rt_nap(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'zoom',1.000000));
add_module(mymodel,rt_ncm(mymodel,'integrationPeriod',0.500000));
add_module(mymodel,rt_pesq(mymodel,'gain',1.000000,'integrationPeriod',0.500000));
add_module(mymodel,rt_pitch(mymodel,'algorithm','NCF - Normalized Correlation Function','OverlapLength',1.000000,'WindowLength',1.000000,'Range',[50.000000,400.000000],'MedianFilterLength',1.000000));
add_module(mymodel,rt_pitchshifter(mymodel,'PitchShift',8.000000,'overlap',0.300000));
add_module(mymodel,rt_reverb(mymodel,'PreDelay',0.100000,'Diffusion',0.500000,'DecayFactor',0.500000,'WetDryMix',0.300000));
add_module(mymodel,rt_roughness(mymodel));
add_module(mymodel,rt_sai(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'zoom',1.000000));
add_module(mymodel,rt_sharpness(mymodel,'integrationPeriod',0.400000));
add_module(mymodel,rt_space(mymodel,'azimuth',0.000000,'elevation',0.000000));
add_module(mymodel,rt_specsub(mymodel,'Thres',3.000000,'alpha',2.000000,'FLOOR',0.002000,'G',0.900000));
add_module(mymodel,rt_spectrum(mymodel,'WindowLength',30.000000,'Overlap',20.000000,'NumberFFTbins','256','WindowFunction','blackmanharris','zoom',1.000000));
add_module(mymodel,rt_spectrum_lpc(mymodel,'WindowLength',30.000000,'Overlap',20.000000,'NumberFFTbins','256','WindowFunction','blackmanharris','zoom',1.000000));
add_module(mymodel,rt_stoi(mymodel,'integrationPeriod',1.000000));
add_module(mymodel,rt_straightvoc(mymodel,'PitchStretch',1.000000,'FrequencyStretch',1.000000,'TimeStretch',1.000000));
add_module(mymodel,rt_strobes(mymodel,'numberChannels',50.000000,'lowest_frequency',100.000000,'highest_frequency',6000.000000,'zoom',1.000000));
add_module(mymodel,rt_telephone(mymodel));
add_module(mymodel,rt_vad(mymodel,'zoom',1.000000,'FFTLength',256.000000,'Window','Hann','SidelobeAttenuation',60.000000,'SilenceToSpeechProbability',0.200000,'SpeechToSilenceProbability',0.100000));
add_module(mymodel,rt_vtl(mymodel));
add_module(mymodel,rt_waveform(mymodel,'zoom',1.000000));
add_module(mymodel,rt_wiener(mymodel,'smoothing_factor_in_apriori',0.980000,'a_priori_speech_probability',0.500000));
add_module(mymodel,rt_add_file(mymodel,'filename','','foldername','/Users/stef/Google Drive/projects/realtime/rttools','attenuation',0.000000));
add_module(mymodel,rt_input_file(mymodel,'MaxFileLeveldB',100.000000,'filename','emergency.wav','foldername','.'));
add_module(mymodel,rt_input_file_random(mymodel,'foldername','.','MaxFileLeveldB',100.000000));
add_module(mymodel,rt_input_microphone(mymodel,'Calibrate',1,'system_input_type','Default','CalibrationFile','zerocalibration.m'));
add_module(mymodel,rt_input_oscillator(mymodel,'SignalType','sine','Frequency',1000.000000,'Amplitude',80.000000,'NumTones',1,'DutyCycle',0.500000,'Width',0.500000,'TimeConstant',0.010000,'Period',0.010000,'NrPulses',4,'PulsesEvery',1.000000,'NoiseColor','pink'));
add_module(mymodel,rt_input_output(mymodel,'Calibrate',0,'Direction','first record then play','InGains','0,0,0,0,0,0,0,0,0,0','OutGains','0,0,0,0,0,0,0,0,0,0'));
add_module(mymodel,rt_input_var(mymodel,'variable',''));
add_module(mymodel,rt_measure_latency(mymodel));
add_module(mymodel,rt_output(mymodel));
add_module(mymodel,rt_output_file(mymodel,'filename','emergencyoutput.wav','foldername','.'));
add_module(mymodel,rt_output_speaker(mymodel,'Calibrate',1,'system_output_type','Default','CalibrationFile','AKG_K271_MkII_1_3_octave.m'));
add_module(mymodel,rt_output_var(mymodel,'variable_name','res'));

