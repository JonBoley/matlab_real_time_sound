%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_input_mic < rt_input
    properties
        recorder;
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_input_mic(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'system_input_type','Default');
            parse(pars,varargin{:});
            obj.fullname=sprintf('microphone input: %s',pars.Results.system_input_type);
            pre_init(obj);  % add the parameter gui           
            add(obj.p,param_generic('system_output_type',pars.Results.system_input_type));
            
            obj.input_source_type='mic'; % I am a microphone
%             obj.show=1;  % show me as selectable to the user

        end
        
        function post_init(obj) % called the second times around
            post_init@rt_module(obj);
            
            afr = audioDeviceReader;
            afr.SamplesPerFrame=obj.parent.FrameLength;
            afr.SampleRate=obj.parent.SampleRate;
            afr.NumChannels=obj.parent.Channels;
            afr.Device=getvalue(obj.p,'system_output_type');
            
            obj.parent.recorder=afr;
            
        end
        
        function sig=read_next(obj)
            sig = obj.parent.recorder();
            sig=input_calibrate(obj,sig);
        end
        
        function close(obj)
            if ~isempty(obj.parent.recorder)
                release(obj.parent.recorder);
            end
        end
    end
end
