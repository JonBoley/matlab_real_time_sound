function [y,delays,gains] = shiftPitch(x,pitch,overlap,Fs,resetFlag)
% shiftPitch This function is used in DelayBasedPitchShifterExample.

%  Copyright 2015-2016 The MathWorks, Inc.

%#codegen

persistent pitchShifter
if isempty(pitchShifter)
    pitchShifter = audiopluginexample.PitchShifter( ...
        'PitchShift',8,'Overlap',0.3);
    setSampleRate(pitchShifter,Fs);
end

y = zeros(size(x),'like',x);
delays = zeros(size(x,1),2);
gains = zeros(size(x,1),2);

if nargin > 4 && resetFlag
    reset(pitchShifter);
    return;
end

pitchShifter.PitchShift = pitch;
pitchShifter.Overlap = overlap;

[y,delays,gains] = pitchShifter(x);

end
