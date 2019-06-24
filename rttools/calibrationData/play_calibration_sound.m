%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function play_calibration_sound(fre,amp)

mymodel=rt_model('SampleRate',44100,'FrameLength',256,'Channels',1,'Duration',5);
add_module(mymodel,rt_input_oscillator(mymodel,'SignalType','sine','Frequency',fre,'Amplitude',amp));
add_module(mymodel,rt_output_speaker(mymodel,'Calibrate',0));
initialize(mymodel);
run_once(mymodel);
close(mymodel);

end