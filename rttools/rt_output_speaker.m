%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% input module, can return signals
classdef rt_output_speaker < rt_output
    properties
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_output_speaker(parent,varargin) %% called the very first time around
            obj@rt_output(parent,varargin{:});
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'system_output_type','Default');
            parse(pars,varargin{:});
            obj.fullname=sprintf('speaker output: %s',pars.Results.system_output_type);
            pre_init(obj);  % add the parameter gui
            add(obj.p,param_generic('system_output_type',pars.Results.system_output_type));
            
            obj.output_drain_type='speaker'; % I am a speaker (or headphone)
%             obj.show=1;
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_output(obj);
            if ~isempty(obj.parent.player) % first release the old one
                release(obj.parent.player);
            end
            target=getvalue(obj.p,'system_output_type');
            obj.parent.player =  audioDeviceWriter('SampleRate',obj.parent.SampleRate,'Device',target);
            setup(obj.parent.player,zeros(obj.parent.FrameLength,obj.parent.Channels));
        end
        
        function write_next(obj,sig)
            sig=output_calibrate(obj,sig);
            obj.parent.player(sig);
        end
        
        function close(obj)
            if ~isempty(obj.parent.player) % first release the old one
                release(obj.parent.player);
            end
        end
    end
end
