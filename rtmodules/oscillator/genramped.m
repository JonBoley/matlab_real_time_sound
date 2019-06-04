

function s=genramped(sr,len,phase,params)
% generates ramped sinusoids regular or irregular

fc=getvalue(params,'Frequency','Hz');
damped_time=getvalue(params,'TimeConstant','sec');
period_length=getvalue(params,'Period','sec');
% jitter=get(params,'Jitter');
mode=getvalue(params,'SignalType');


x=zeros(len,1); % create an empty return
x=sin(2*pi*fc*[1:len]/sr); % create a sine wave

s=x;



