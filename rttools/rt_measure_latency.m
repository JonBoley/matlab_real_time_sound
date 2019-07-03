%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% tool module that correlates the input against an output

classdef rt_measure_latency < rt_measurer
    properties
        in_buffer
        out_buffer
    end
    
    methods
        function obj=rt_measure_latency(parent,varargin) %% called the very first time around
            obj@rt_measurer(parent,varargin{:});
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            parse(pars,varargin{:});
            obj.fullname='measure latency';
            
            pre_init(obj);  % add the parameter gui
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_measurer(obj);
            
            sr=obj.parent.SampleRate;
            obj.in_buffer=circbuf1(1*sr);
            obj.out_buffer=circbuf1(1*sr);
            
        end
        
        function result=calculate(obj,sig)
            push(obj.out_buffer,obj.parent.last_played_stim);
            push(obj.in_buffer,obj.parent.last_recorded_stim);
            
            
            result=-1;
        end
        
        function close(obj)
            % we use this as an opportunity to calculate the results :)
            out=get(obj.out_buffer);
            out=out/rms(out);
            in=get(obj.in_buffer);
            in=in/rms(in);

            figure(1)
            clf
            subplot(2,1,1);
            hold on
            plot(out)
            plot(in)
            legend({'played via speaker';'recorded via microphone'})
            
            
            sr=obj.parent.SampleRate;
            
            %             sound(in,sr)
            subplot(2,1,2);
            hold on
            maxlag=0.2*sr; % max latency = 50 ms
            sout=out(round(0.5*sr):end);
            sin=in(round(0.5*sr):end);
            [r,lags] = xcorr(sin,sout,maxlag);
            h=ceil(length(r)/2);
            sint=r(h:end);
            lint=lags(h:end);
            lint=lint/sr*1000; % ms
            plot(lint,sint)
            xlabel('time (ms)')
            ylabel('correlation');
            
            [pks,loc]=findpeaks(sint,sr,'SortStr','descend');
            plot(loc(1)*1000,pks(1),'or');
            ttt=sprintf('%2.1f ms',loc(1)*1000);
            text((loc(1)*1000)+5,pks(1),ttt,'fontsize',20);
            disp(ttt);
        end
        
    end
end
