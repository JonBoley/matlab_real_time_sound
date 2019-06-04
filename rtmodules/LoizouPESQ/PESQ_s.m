function PESQ_s(block)
setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 2;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% % % Override input port properties
block.InputPort(1).SamplingMode = 'Frame';
block.InputPort(1).Dimensions  = [-1 -1];
% block.InputPort(1).Dimensions        = 2;
% block.InputPort(1).DatatypeID  = 0;  % double
% block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

%http://www.mathworks.co.uk/help/simulink/sfg/input-and-output-ports.html
block.SetPreCompInpPortInfoToDynamic; % set input ports to be dynamic

% % Override output port properties
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';
block.OutputPort(1).Dimensions  = [1 1];

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
block.SampleTimes = [-1 0];

block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('SetInputPortDimensions', @SetInpPortDims);

function SetInpPortDims(block, idx, fd)
block.InputPort(1).Dimensions = fd;
block.InputPort(2).Dimensions = fd;

function Outputs(block)

ref_data=block.InputPort(1).Data;
deg_data=block.InputPort(2).Data;

sampling_rate=16000;

global Downsample DATAPADDING_MSECS SEARCHBUFFER Fs WHOLE_SIGNAL
global Align_Nfft Window 

setup_global(sampling_rate);

TWOPI= 6.28318530717959;

count=0:Align_Nfft- 1;
Window= 0.5 * (1.0 - cos((TWOPI * count) / Align_Nfft));

ref_data= ref_data'.* 32768;
ref_Nsamples= length( ref_data)+ 2* SEARCHBUFFER* Downsample;
ref_data= [zeros( 1, SEARCHBUFFER* Downsample), ref_data, ...
    zeros( 1, DATAPADDING_MSECS* (Fs/ 1000)+ SEARCHBUFFER* Downsample)];

deg_data= deg_data'.* 32768;
deg_Nsamples= length( deg_data)+ 2* SEARCHBUFFER* Downsample;
deg_data= [zeros( 1, SEARCHBUFFER* Downsample), deg_data, ...
    zeros( 1, DATAPADDING_MSECS* (Fs/ 1000)+ SEARCHBUFFER* Downsample)];

maxNsamples= max( ref_Nsamples, deg_Nsamples);

ref_data= fix_power_level( ref_data, ref_Nsamples, maxNsamples);
deg_data= fix_power_level( deg_data, deg_Nsamples, maxNsamples);

standard_IRS_filter_dB= [0, -200; 50, -40; 100, -20; 125, -12; 160, -6; 200, 0;...    
    250, 4; 300, 6; 350, 8; 400, 10; 500, 11; 600, 12; 700, 12; 800, 12;...
    1000, 12; 1300, 12; 1600, 12; 2000, 12; 2500, 12; 3000, 12; 3250, 12;...
    3500, 4; 4000, -200; 5000, -200; 6300, -200; 8000, -200]; 

ref_data= apply_filter( ref_data, ref_Nsamples, standard_IRS_filter_dB);
deg_data= apply_filter( deg_data, deg_Nsamples, standard_IRS_filter_dB);
% 


% for later use in psychoacoustical model
model_ref= ref_data;
model_deg= deg_data;

[ref_data, deg_data]= input_filter( ref_data, ref_Nsamples, deg_data, ...
    deg_Nsamples);


[ref_VAD, ref_logVAD]= apply_VAD( ref_data, ref_Nsamples);
[deg_VAD, deg_logVAD]= apply_VAD( deg_data, deg_Nsamples);


crude_align (ref_logVAD, ref_Nsamples, deg_logVAD, deg_Nsamples,...
    WHOLE_SIGNAL);

utterance_locate (ref_data, ref_Nsamples, ref_VAD, ref_logVAD,...
    deg_data, deg_Nsamples, deg_VAD, deg_logVAD);

ref_data= model_ref;
deg_data= model_deg;

% make ref_data and deg_data equal length
if (ref_Nsamples< deg_Nsamples)
    newlen= deg_Nsamples+ DATAPADDING_MSECS* (Fs/ 1000);
    ref_data( newlen)= 0;
elseif (ref_Nsamples> deg_Nsamples)
    newlen= ref_Nsamples+ DATAPADDING_MSECS* (Fs/ 1000);
    deg_data( newlen)= 0;
end


pesq_mos= pesq_psychoacoustic_model (ref_data, ref_Nsamples, deg_data, ...
    deg_Nsamples );


























block.OutputPort(1).Data = pesq_mos;

