
% test all modules in the directory for errors and speed
cd('/Users/bleeck/Google Drive/projects/realtime');
clear all
close all force
clc
addpath(genpath('./rttools'));
addpath(genpath('./rtmodules'));

%   Copyright 2019 Stefan Bleeck, University of Southampton
%wanted:
wanted='rt_amplify.m';

% f=uifigure('Units','pixel');
% f1=uipanel(f,'Position',[1 1 400 200]);
% f2=uipanel(f,'Position',[1 201 400 200]);
f1=[];f2=[];

wdir='rtmodules';
base_d=cd(wdir);
l=dir();
obj=[];
for i=1:length(l)
    ll=l(i).name;
    %     ll
    if contains(ll,'.m') && ~contains(ll,'~')
        %         i
        if isequal(ll,wanted)
            name=ll(1:end-2);
            str=sprintf('o=%s(obj);',name);
            eval(str);
            ud=cd(base_d);
            runo(o,f1,f2);
            base_d=cd(ud);
        end
    end
end
cd(base_d);


function runo(obj,f1,f2)

if obj.show==0
    fprintf('not running module ''%s''\n\n\n',obj.fullname);
    return
end

parent=[]; % just for show doesn't need to do anything
parent.viz_panel=f1;
parent.meas_panel=f2;


m=rtmodel(parent);
m.Fs=22050;m.frame_length=256;
filename='/Users/bleeck/Google Drive/projects/realtime/bkb.wav';% input: always the same wav file
d=audioinfo(filename); %load the wave for further info
length_s=d.Duration; % how long is the file?

inp=rt_input_file(m,'filename',filename,'foldername','/Users/bleeck/Google Drive/projects/realtime');
m=add_module(m,inp);

% obj is the only model that we investiate:
m=add_module(m,obj);


% save to a file
% out=rtoutput_speaker(m,'Default');

%             ADR = audioDeviceWriter;
%             devices=getAudioDevices(ADR);

out=rt_output_speaker(obj,'system_output_type','Default');
m=add_module(m,out);

howmany='once';
% howmany='many';
% howmany='oneframe';


tic
switch howmany
    case 'oneframe'
        m.frame_length=m.Fs*length_s;
        setvalue(obj.p,'integrationPeriod',length_s); % make sure it's integrating only once over the whole period
        m=initialize(m);
        run_sigle_frame(m); % simulate for the duration of the file
    case 'once'
        m=initialize(m);
        s=save_script_file(m,'myscript.m');
        run_once(m); % simulate for the duration of the file
    case 'many'
        m=initialize(m);
        run(m); % simulate infinetly
end



t=toc;
fprintf('finished. real time factor: %2.3f %%\n\n',length_s/t*100);

end
