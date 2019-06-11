%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% test all modules in the directory for errors, messages and speed
cd('/Users/bleeck/Google Drive/projects/realtime');
clear all
close all force
clc
addpath(genpath('./rttools'));
addpath(genpath('./rtmodules'));
addpath(genpath('./thirdparty'));

wdir='rtmodules';
base_d=cd(wdir);
allfiles=dir();
obj=[];
r=[];c=0;
for i=1:length(allfiles)
    ll=allfiles(i).name;
    %     ll
    if contains(ll,'.m') && ~contains(ll,'~')
        %         i
        name=ll(1:end-2);
        fprintf('%d: starting %s',i,name);
        str=sprintf('o=%s(obj);',name);
        eval(str);
        ud=cd(base_d);
        c=c+1;
        rr=runo(o);
        if ~isempty(rr)
            r{c}=rr;
        end
        base_d=cd(ud);
        fprintf(' finished\n');

% clear all
close all force
    end
end
cd(base_d);

c=0;
rnn=[];
for i=1:length(r)
    i
    if ~isempty(r{i})
        c=c+1;
        rnn{c}=r{i};
    end
end

save_excel(rnn,'fullinfo.csv');

function res=runo(mod)

runtime=1;




mymodel=rt_model('SampleRate',22050,'FrameLength',mod.requires_frame_length,'Channels',mod.requires_nr_channels,'Duration',runtime,'OverlapAdd',mod.requires_overlap_add);
module_1=rt_input_file_random(mymodel,'foldername','./randomwavs');
add_module(mymodel,module_1);

if mod.requires_noise
    module_2=rt_add_file(mymodel,'foldername','./noises','filename','Pink.wav');
    add_module(mymodel,module_2);
end

add_module(mymodel,mod);

gui(mymodel);
initialize(mymodel);
tic
run_once(mymodel);

res.filename=mod.modname;
res.manipulator=mod.is_manipulation;
res.visuzlizer=mod.is_visualization;
res.measurement=mod.is_measurement;
res.input=mod.is_input;
res.output=mod.is_output;
res.requires_noise=mod.requires_noise;  % this module requires a clean signal and a noise signal (haspi, ibm, etc)
res.requires_nr_channels=mod.requires_nr_channels; % the number of channels required minimum. usually one
res.requires_overlap_add=mod.requires_overlap_add; % this module requires overlap and add switched on to work properly

res.fullname=mod.fullname;
res.speed=2/toc*100;
res.description=mod.descriptor;

end
