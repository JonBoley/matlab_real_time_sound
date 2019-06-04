function phone_sim_s(block)

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
block.InputPort(1).Dimensions  = [8000 1];
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
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1 0];

block.RegBlockMethod('Outputs', @Outputs);     % Required


function Outputs(block)

input=block.InputPort(1).Data;
fs=22050;
szp=[0.19892796195357i; -0.48623571568937+0.86535995266875i]; 
szp=[[0; -0.97247143137874] szp conj(szp)];
% s-plane zeros and poles of high pass 3'rd order chebychev2 filter with -3dB at w=1
zl=2./(1-szp*tan(300*pi/fs))-1;
al=real(poly(zl(2,:)));
bl=real(poly(zl(1,:)));
sw=[1;-1;1;-1];
bl=bl*(al*sw)/(bl*sw);
zh=2./(szp/tan(3400*pi/fs)-1)+1;
ah=real(poly(zh(2,:)));
bh=real(poly(zh(1,:)));
bh=bh*sum(ah)/sum(bh);
b=conv(bh,bl);
a=conv(ah,al);


% [b,a]=potsband(fs);

output=filter(b,a,input);

% mm=max(abs(output));
% output=output.*output;
% output=output./mm;

block.OutputPort(1).Data = output;




