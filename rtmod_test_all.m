%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)
% this script runs and test all modules in the directory for errors, messages and speed
% it saves a csv file with all information about speed. To build up a library of computer resources required, it would be really 
% useful if you would send me a copy of this csv file! Thanks! :)

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
res_save=[];c=0;
for i=1:length(allfiles)
    ll=allfiles(i).name;
    %     ll
    if contains(ll,'.m') && ~contains(ll,'~')
        %         i
        name=ll(1:end-2);
        fprintf('%d: starting %s ... ',i,name);
        str=sprintf('o=%s(obj);',name);
        eval(str);
        ud=cd(base_d);
        c=c+1;
        rr=runo(o);
        if ~isempty(rr)
            res_save{c}=rr;
        end
        base_d=cd(ud);
        fprintf(' ...finished\n');
        
        % clear all
        close all force
    end
end
cd(base_d);

c=0;
rnn=[];
for i=1:length(res_save)
    if ~isempty(res_save{i})
        c=c+1;
        rnn{c}=res_save{i};
    end
end

% now add the benchmark info too:
a=bench(1);
a=mean(a,1);


r=resempty;
r.filename='Matlab Bench';
r.speed=a;
c=c+1;
rnn{c}=r;
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


res=resempty;
res.filename=mod.modname;
res.manipulator=mod.is_manipulation;
res.visualizer=mod.is_visualization;
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


function res=resempty
res.filename='';
res.manipulator='';
res.visualizer='';
res.measurement='';
res.input='';
res.output='';
res.requires_noise='';
res.requires_nr_channels='';
res.requires_overlap_add='';
res.fullname='';
res.speed='';
res.description='';
end
