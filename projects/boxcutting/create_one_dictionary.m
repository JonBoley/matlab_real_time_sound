% function to create only one set of features

function res=create_one_dictionary(fname)
[x,fs]=audioread(fname);
l=length(x)/fs;

mymodel=rt_model('SampleRate',fs,'FrameLength',128,'Channels',1,'Duration',l,'OverlapAdd',0,'PlotWidth',l);
add_module(mymodel,rt_input_file(mymodel,'filename',fname));
% add_module(mymodel,rt_spectrum(mymodel));
add_module(mymodel,rt_sai_boxcutting(mymodel));

% gui(mymodel);
initialize(mymodel);
run_once(mymodel);
close(mymodel);

res=mymodel.measurement_result;
end
