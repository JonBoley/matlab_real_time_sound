%% Delay-Based Pitch Shifter
% This example shows an audio plugin designed to shift the pitch of a sound
% in real time.

% Copyright 2015-2019 The MathWorks, Inc.

%% Algorithm
% The figure below illustrates the pitch shifting algorithm.
%
% <<../pitchShiftAlg.png>>
%
% The algorithm is based on cross-fading between two channels with
% time-varying delays and gains. This method takes advantage of the
% pitch-shift Doppler effect that occurs as a signal's delay is increased
% or decreased.
%
% The figure below illustrates the variation of channel delays and gains
% for an upward pitch shift scenario: The delay of channel 1 decreases at a
% fixed rate from its maximum value (in this example, 30 ms). Since the
% gain of channel 2 is initially equal to zero, it does not contribute to
% the output. As the delay of channel 1 approaches zero, the delay of
% channel 2 starts decreasing down from 30 ms. In this cross-fading region,
% the gains of the two channels are adjusted to preserve the output power
% level. Channel 1 is completely faded out by the time its delay reaches
% zero. The process is then repeated, going back and forth between the two
% channels.
%
% <<../pitchShiftChannels.png>>
%
% For a downward pitch effect, the delays are increased from zero to the
% maximum value.
%
% The desired output pitch may be controlled by varying the rate of change
% of the channel delays. Cross-fading reduces the audible glitches that
% occur during the transition between channels. However, if cross-fading
% happens over too long a time, the repetitions present in the overlap area
% may create spurious modulation and comb-filtering effects.

%% Pitch Shifter Audio Plugin
% <matlab:edit('audiopluginexample.PitchShifter')
% audiopluginexample.PitchShifter> is an audio plugin object that
% implements the delay-based pitch shifting algorithm. The plugin
% parameters are the pitch shift (in semi-tones), and the cross-fading
% factor (which controls the overlap between the two delay branches). You
% can incorporate the object into a MATLAB simulation, or use it to
% generate an audio plugin using
% <matlab:web(fullfile(docroot,'audio/ref/generateaudioplugin.html'),'-helpbrowser')
% generateAudioPlugin>.
%
% In addition to the output audio signal, the object returns two extra
% outputs, corresponding to the delays and gains of the two channels,
% respectively.
%
% You can open a test bench for |audiopluginexample.PitchShifter| by using
% <matlab:web(fullfile(docroot,'audio/ref/audiotestbench-app.html'),'-helpbrowser')
% audioTestBench>. The test bench provides a user interface (UI) to help
% you test your audio plugin in MATLAB. You can tune the plugin parameters
% as the test bench is executing. You can also open a
% <matlab:web(fullfile(docroot,'dsp/ref/dsp.timescope-system-object.html'),'-helpbrowser')
% Time Scope> and a
% <matlab:web(fullfile(docroot,'dsp/ref/dsp.spectrumanalyzer-system-object.html'),'-helpbrowser')
% Spectrum Analyzer> to view and compare the input and output signals in
% the time and frequency domains, respectively.
%
% You can also use |audiopluginexample.PitchShifter| in MATLAB just as you
% would use any other MATLAB object. You can use the
% <docid:audio_ref.bu4zsnv-1 configureMIDI> command to enable tuning the
% object via a MIDI device. This is particularly useful if the object is
% part of a streaming MATLAB simulation where the command window is not
% free.
%
% |shiftPitch| is a simple function that may be used to perform pitch
% shifting as part of a larger MATLAB simulation. The function instantiates
% an |audiopluginexample.PitchShifter| plugin, and uses the setSampleRate
% method to set its sampling rate to the input argument Fs. The plugin's
% parameter's are tuned by setting their values to the input arguments
% pitch and overlap, respectively. Note that it is also possible to
% generate a MEX-file from this function using the codegen command.
% Performance is improved in this mode without compromising the ability to
% tune parameters.

%% MATLAB Simulation
% |audioPitchShifterExampleApp| implements a real-time pitch shifting app.
%
% Execute audioPitchShifterExampleApp| to open the app. In addition to
% playing the pitch-shifted output audio, the app plots the time-varying
% channel delays and gains, as well as the input and output signals.
% 
reader = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav', ...
    'SamplesPerFrame',256,'PlayCount',Inf);
scope = dsp.TimeScope('TimeSpan',.1,'YLimits',[-1,1], ...
    'SampleRate',reader.SampleRate,'LayoutDimensions',[3 1], ...
    'NumInputPorts',3,'TimeSpanOverrunAction','Scroll');
scope.ActiveDisplay = 1;
scope.Title = 'Delays';
scope.YLabel = 'Delay (ms)';
scope.ShowGrid = true;
scope.YLimits = [0,30];
scope.ActiveDisplay = 2;
scope.Title = 'Gains';
scope.YLabel = 'Amplitude';
scope.ShowGrid = true;
scope.YLimits = [0,1];
scope.ActiveDisplay = 3;
scope.Title = 'Input vs. Output Signals';
scope.YLabel = 'Amplitude';
scope.ShowGrid = true;
scope.YLimits = [-1,1];
for index = 1:500
    x = reader();
    [y,delays,gains] = shiftPitch(x,8,0.1,reader.SampleRate);
    scope(delays,gains,[x,y]);
end
%%
% |audioPitchShifterExampleApp| opens a UI designed to interact with the
% simulation. The UI allows you to tune the parameters of the pitch
% shifting algorithm, and the results are reflected in the simulation
% instantly. The plots reflects your changes as you tune these parameters.
% For more information on the UI, call |help HelperCreateParamTuningUI|.
%
% |audioPitchShifterExampleApp| wraps around |HelperPitchShifterSim| and
% iteratively calls it. |HelperPitchShifterSim| instantiates, initializes
% and steps through the objects forming the algorithm.
%
% MATLAB Coder can be used to generate C code for |HelperPitchShifterSim|.
% In order to generate a MEX-file for your platform, execute
% |HelperPitchShifterCodeGeneration| from a folder with write permissions.
%
% By calling |audioPitchShifterExampleApp| with  |'true'| as an argument,
% the generated MEX-file |HelperPitchShifterSimMEX| can be used instead of
% |HelperPitchShifterSim| for the simulation. In this scenario, the UI is
% still running inside the MATLAB environment, but the main processing
% algorithm is being performed by a MEX-file. Performance is improved in
% this mode without compromising the ability to tune parameters.
%
% Call |audioPitchShifterExampleApp| with |'true'| as argument to
% use the MEX-file for simulation. Again, the simulation runs till the user
% explicitly stops it from the UI.

%% References
%
% [1] 'Using Multiple Processors for Real-Time Audio Effects', 	Bogdanowicz,
%     K. ; Belcher, R;  AES - May 1989.
%
% [2] 'A Detailed Analysis of a Time-Domain Formant-Corrected Pitch-Shifting 
%     Algorithm', Bristow-Johnson, R. ; AES - October 1993.
