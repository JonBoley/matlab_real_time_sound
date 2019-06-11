function scopeHandles = audioPitchShifterExampleApp( ...
    usemex,showVisual,numTSteps)
%audioPitchShifterExampleApp Graphical interface for audio pitch shifter. 
%
% Inputs:
%   usemex     - If true, MEX-file is used for simulation for the
%                algorithm. Default value is false. Note: in order to use
%                the MEX file, first execute:
%                codegen HelperPitchShifterSim -o HelperPitchShifterSimMEX
%   showVisual - Display scopes
%   numTSteps  - Number of time steps. Default value is infinite
%
% Output:
%   scopeHandles - Handle to scopes
%
% This function audioPitchShifterExampleApp is only in support of
% audioPitchShifterExample. It may change in a future release.

% Copyright 2015-2017 The MathWorks, Inc.

%#codegen

%% Default values for inputs
if nargin < 3
    numTSteps = Inf; % Run until user stops simulation. 
end
if nargin < 2
    showVisual = true; % Plot results  
end
if nargin == 0
    usemex = false; % Do not generate code.
end

screen = get(0,'ScreenSize');
outerSize = min((screen(4)-40)/2, 512);
    
% Create scopes only if plotResults is true
if showVisual                         
    scope = dsp.TimeScope('TimeSpan',0.1,'YLimits',[-1 1], ...
        'SampleRate',44100,'LayoutDimensions',[3 1], ...
        'NumInputPorts',3,'TimeSpanOverrunAction','Scroll');
    scope.ActiveDisplay = 1;
    scope.Title = 'Delays';
    scope.YLabel = 'Delay (ms)';
    scope.ShowGrid = true;
    scope.YLimits = [0 30];
    scope.ActiveDisplay = 2;
    scope.Title = 'Gains';
    scope.YLabel = 'Amplitude';
    scope.ShowGrid = true;
    scope.YLimits = [0 1];
    scope.ActiveDisplay = 3;
    scope.Title = 'Input vs. Output Signals';
    scope.YLabel = 'Amplitude';
    scope.ShowGrid = true;
    scope.YLimits = [-1 1];
else
    scope = [];
end

% Define parameters to be tuned
param = struct([]);
param(1).Name = 'Pitch Shift (Semi-Tones)';
param(1).InitialValue = 8;
param(1).Limits = [-12 12];
param(2).Name = 'Overlap';
param(2).InitialValue = 0.3;
param(2).Limits = [0.01 0.5];
% Create the UI and pass it the parameters
tuningUI = HelperCreateParamTuningUI(param,'Pitch Shifter');
set(tuningUI,'Position',[outerSize+32, screen(4)-2*outerSize+8, ...
    outerSize+8, outerSize-92]);

clear HelperPitchShifterSim
clear HelperPitchShifterSimMEX
clear shiftPitch

% Execute algorithm
while(numTSteps >= 0)
    
    S = HelperUnpackUIData(tuningUI);
    
    if S.Stop     % If "Stop Simulation" button is pressed
        break;
    end
    
    if S.Pause
        continue;
    end
    
    if ~usemex
        [x,y,delays,gains] = HelperPitchShifterSim(S);
    else
        [x,y,delays,gains] = HelperPitchShifterSimMEX(S);
    end
    
    if showVisual
        scope(1000*delays,gains,[x,y]);
    end
    numTSteps = numTSteps - 1;
end

if ishghandle(tuningUI)  % If parameter tuning UI is open, then close it.
    delete(tuningUI);
    drawnow;
    clear hUI
end
  
if showVisual
    release(scope);
    scopeHandles.scope = scope;
end

clear HelperUnpackUIData
clear HelperPitchShifterSim
clear HelperPitchShifterSimMEX