
function sig=aim_reconstruct(bmm,nap,strobes,sai,simparams)
sig=zeros(1,size(bmm,2));
frame_len=length(sig);
sai_len=size(sai,2);
nrc=size(sai,1); % nr channels
sai_window_length = 1 + floor(1/simparams(1)*35/1000);
num_channels=simparams(2);
sample_rate=simparams(1);fs=1/sample_rate;
% how many frames do I need to cover the length of a SAI?
nr_sai_frame=ceil(sai_window_length/frame_len);

persistent future_buffer time_shift

if isempty(future_buffer)
    %     pframe=zeros(nr_sai_frame,sai_window_length); % save all sais from past
    future_buffer=single(zeros(num_channels,(nr_sai_frame+1)*frame_len,1)); % storage for the following frames that are effected
    centre_frequencies=calc_centre_frequencies(num_channels,simparams(3),simparams(4));
    
    % time shift all strobes backwards to align them in the past. Equation
    % from Wolfram Alpha: find "derivative of x^3 exp(-2 pi b x)"
    % solution "-e^(-2 b pi x) x^2 (-3+2 b pi x)"
    % then "solve -e^(-2 b pi x) x^2 (-3+2 b pi x)=0"
    % x=0.47746/b (with b=1.019*ERB);
    
    EarQ = 9.26449;				%  Glasberg and Moore Parameters
    minBW = 24.7;
    
    ERB = centre_frequencies/EarQ + minBW;
    B=1.019*ERB;
    
    time_shift=0.47746./B;
    time_shift=floor(time_shift./sample_rate);
    
   
end

% shift the storage buffer to the next frame
future_buffer(:,1:end-frame_len+1)=future_buffer(:,frame_len:end);
future_buffer(:,frame_len:end)=0;

% linear ramp off the first 5 ms.
ramp_dur=floor(0.002/sample_rate);
ll=linspace(0,1,ramp_dur);
for ch=1:nrc
    sai(ch,1:ramp_dur)=sai(ch,1:ramp_dur).*ll;
end


% prinicple: fill up storage buffer at each new strobes with the next 35 ms SAI
for ch=45:45
    current_sai=sai(ch,:);
    st=strobes(ch,:);
    st=st(st>0);    % select only the ones that really happend
    % time shift them
    st=st-time_shift(ch);
    
    for ii=1:length(st)
        strobe_bin=st(ii); % point of specific strobe
        if strobe_bin>0 % positive ones can just be added
            % fill in the future buffer
            future_buffer(ch,strobe_bin:sai_len+strobe_bin-1)=future_buffer(ch,strobe_bin:sai_len+strobe_bin-1)+current_sai;
        else % negative ones need to be shifted
            shift=-strobe_bin;
            future_buffer(ch,1:sai_len-shift)=future_buffer(ch,1:sai_len-shift)+current_sai(shift+1:end);
%             future_buffer(ch,strobe_bin:sai_len+strobe_bin-1)=future_buffer(ch,strobe_bin:sai_len+strobe_bin-1)+current_sai;
        end
        figure(3),clf,hold on
        plot(future_buffer(ch,:))
        audioplayer(future_buffer(ch,:)*1000,4000)

    end
end


sig=sum(future_buffer(:,1:frame_len));
return

