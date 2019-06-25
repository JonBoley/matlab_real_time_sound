%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function amp=measure_calibration_sound(fre,input)
len=1;
mymodel=rt_model('SampleRate',44100,'FrameLength',256,'Channels',1,'Duration',len);
add_module(mymodel,rt_input_microphone(mymodel,'Calibrate',0,'system_input_type',input));
add_module(mymodel,rt_dBSPL(mymodel,'Bandwidth','1/12 octave','IntegrationTime',len));
initialize(mymodel);
run_once(mymodel);

avals=zeros(length(mymodel.measurement_result),length(mymodel.measurement_result{1}.freq));
for i=1:length(mymodel.measurement_result)
    for j=1:length(mymodel.measurement_result{1}.freq)
        v=mymodel.measurement_result{i}.fmeas(j); % final measumrents
        if ~isinf(v)
            avals(i,j)=v;
        end
    end
end
favals=mean(avals);
close(mymodel);

% find the measured db value at the specified frequency. Don't rely on
% that it's in the list
x=log(mymodel.measurement_result{1}.freq);
y=favals;
amp=interp1(x,y,log(fre));

end