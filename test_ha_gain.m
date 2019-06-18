clear all
clc
close all force
addpath(genpath('./rttools'));
addpath(genpath('./rtmodules'));
addpath(genpath('./thirdparty'));

mymodel=rt_model('SampleRate',22050,'FrameLength',256,'Channels',1,'Duration',0.1,'OverlapAdd',0,'PlotWidth',1);

module_1=rt_input_oscillator(mymodel,'SignalType','sine','Frequency',1000,'Amplitude',70);
% module_1=rt_input_oscillator(mymodel,'SignalType','noise','NoiseColor','pink','Amplitude',70);
add_module(mymodel,module_1);
p=getparameter(module_1.p,'Amplitude');
comp=[-50,20];
module_2=rt_hearingaid(mymodel,'CentreFrequencies','250,500,1000,2000,4000','AttackTime',0.001,'ReleaseTime',0.001,'band1_250Hz',comp,'band2_500Hz',comp,'band3_1000Hz',comp,'band4_2000Hz',comp,'band5_4000Hz',comp);
add_module(mymodel,module_2);
module_3=rt_dBSPL(mymodel,'Bandwidth','1 octave');
add_module(mymodel,module_3);
% gui(mymodel);
initialize(mymodel);

c=0;
aamp=0:5:100;
for i=1:length(aamp)
    setvalue(p,aamp(i));
    run_once(mymodel);
    %     c=c+1; res(c)=0;
    %     for j=1:3
    c=c+1;
    res(c)=mymodel.measurement_result{end}.fmeas(4);
    %     end
    %     res(c)=res(c)/3;
    reset(mymodel);
end
close(mymodel);

figure(1)
clf
hold on
line([0 100],[0 100],'color','r')
plot(aamp,res,'o-b');
set(gca,'ylim',[-5 105])
