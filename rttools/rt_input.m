%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_input < rt_module
    properties
        last_gain;
        input_source_type; % variable to store information what I am, file or microphone
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_input(parent,varargin) %% called the very first time around
            obj@rt_module(parent,varargin{:});
            obj.fullname='generic input';
            obj.is_input=1;
            obj.input_source_type='not specified';
%             obj.show=0; % don't show me to the user
        end
       
        function duration=get_file_duration(obj)
            duration=inf; % in the base class, return inf, so that the model keeps running
        end
        
        function obj=post_init(obj) % called the second times around
            post_init@rt_module(obj);
        end
        
        function sig=read_next(obj)
        end
        
        function close(obj)
        end
        
        function change_parameter(obj)
            gui(obj.p);
        end
        
        
        function flnew=calc_frame_length(obj,fs1,fs2,fl)
            flnew=floor(fl*fs1/fs2);
            % see if it works!
            ns=zeros(flnew,1);
            ns2=resample(ns,fs2,fs1);
            if length(ns2)==fl
                return
            else
                flnew=flnew+1;
                ns=zeros(flnew,1);
                ns2=resample(ns,fs2,fs1);
                if length(ns2)==fl
                    return
                end
            end
            disp('rt_input: problem: sample rates cannot match requested frame length');
        end
        
        function sig=input_calibrate(obj,sig)
            [ingain,incalib]=get_input_calib(obj.parent,obj);
            
            fac=power(10,(ingain+incalib)/20);
            sig=sig.*fac;
        end
    end
    
end
