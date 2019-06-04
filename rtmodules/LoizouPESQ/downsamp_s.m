function downsamp_s(block)
setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% % % Override input port properties
block.InputPort(1).SamplingMode = 'Frame';
block.InputPort(1).Dimensions  = [11025 1];
% block.InputPort(1).Dimensions        = 2;
% block.InputPort(1).DatatypeID  = 0;  % double
% block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;


% % Override output port properties
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Frame';
block.OutputPort(1).Dimensions  = [8000 1];

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
block.SampleTimes = [-1 0];

block.RegBlockMethod('Outputs', @Outputs);     % Required


function Outputs(block)

input=block.InputPort(1).Data;

sampling_rate1=22050;
sampling_rate2=16000;

output=resample(input,sampling_rate2,sampling_rate1);


block.OutputPort(1).Data = output;

