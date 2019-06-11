function [input,output,delays,gains] = HelperPitchShifterSim(tuningUIStruct)
% HELPERPITCHSHIFTERSIM Implements algorithm used in delay-based pitch
% shifter example. This function instantiates, initializes and steps
% through the System objects used in the algorithm.
% 
% You can tune the simulation properties through the UI that
% appears when audioPitchShifterExampleApp is executed.

%   Copyright 2015-2016 The MathWorks, Inc.

%#codegen

persistent reader player Fs pitch overlap
if isempty(reader)
   reader = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav', ...
       'SamplesPerFrame',256,'PlayCount',Inf);
   player = audioDeviceWriter('SampleRate',reader.SampleRate);
   Fs = reader.SampleRate;
   pitch = 8;
   overlap = 0.3;
end

input = zeros(256,1);

if tuningUIStruct.ValuesChanged
    params  = tuningUIStruct.TuningValues;
    pitch   = params(1);
    overlap = params(2);
end

if tuningUIStruct.Reset
   reset(reader);
   % Reset pitch shifter
   shiftPitch(input,pitch,overlap,Fs,true); 
end

x = reader();
[y,delays,gains] = shiftPitch(x,pitch,overlap,Fs);
player(y);

input  = x(:,1);
output = y(:,1);

end