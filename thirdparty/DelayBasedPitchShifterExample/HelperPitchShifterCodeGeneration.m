function HelperPitchShifterCodeGeneration
%HELPERPITCHSHIFTERCODEGENERATION Code generation for pitch shifter example
%
% Run this function to generate a MEX file for the
% HelperPitchShifterSim function. This function
% HelperPitchShifterSim is only in support of
% DelayBasedPitchShifterExample. It may change in a future release.

% Copyright 2016 The MathWorks, Inc.

% Parameters to be tuned
% Pitch shift
% Overlap
ParamStruct.TuningValues = [8 0.3];
ParamStruct.ValuesChanged = false;
ParamStruct.Reset = false;
ParamStruct.Pause = false;
ParamStruct.Stop  = false;

codegen -report HelperPitchShifterSim -args {ParamStruct} -o HelperPitchShifterSimMEX

