%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


function sig=generatedampsinus2(len,carfre,nr_pulses,pulse_dist,amplitude,halflife,jitter,mode)



sinus=generatesinus(sig,carfre,amplitude,0);

% calculate envelope and mult both
envelope=sig;






env_vals=zeros(round(sig_len*sr),1);
t=0;

for i=1:length(env_vals) % just in case, use the whole signal
    t=t+1/sr;
    
    % build one envelope part and use it as blueprint for all
    time_const=halflife/0.69314718;
    env_vals(i)= exp(-(t)/time_const);
    
    % build a gammatone 4th order
    time_const=halflife/5.52; % empirical by solving below 
    env_vals(i)= power(t,3)*exp(-(t)/time_const);
end

env_vals=env_vals./max(env_vals);

% to find the half-time for the gammatone:
% figure(1),clf,hold on
% plot(env_vals);
% 
% for i=1:length(env_vals)-1
% if env_vals(i)==1
%     disp(sprintf('max: %3.1f ms',i/sr*1000));
% end
% 
% if env_vals(i)>=0.5 && env_vals(i+1)<0.5
%     disp(sprintf('half: %3.1f ms',i/sr*1000));
% end
% 
% end


next_pulse=pulse_times(1);
pulse_counter=1;
t=0;
cc=1;
fenv=zeros(size(env_vals));
for i=1:getnrpoints(envelope)
    t=t+1/sr;
    if cc>length(env_vals)
    fenv(i)=0;
    else
    fenv(i)=env_vals(cc);cc=cc+1;
    end
    if t>next_pulse
        cc=1;
        pulse_counter=pulse_counter+1;
        if length(pulse_times)>=pulse_counter
            next_pulse=pulse_times(pulse_counter);
        else
            next_pulse=inf;
        end
    end
end
% 
% 
% figure(1),clf,hold on
% plot(fenv(1:441));
% set(gca,'ylim',[0 1]);



envelope=setvalues(envelope,fenv);
envelope=lowpass_2003(envelope,1000,4);
envelope=envelope/max(envelope)*amplitude; % limit to the given amplitude


if isequal(mode,'ramped')
    fenv=getvalues(envelope);
    fenv=fenv(end:-1:1); % turn it around
    envelope=setvalues(envelope,fenv);
end

% set the envelope and the amplitude
sig=sinus*envelope;

