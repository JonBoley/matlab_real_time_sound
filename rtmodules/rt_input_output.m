

% input module, can return signals
classdef rt_input_output < rt_output & rt_input
    properties
        playerrecorder;
        previous_in
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_input_output(parent,varargin) %% called the very first time around
            obj@rt_output(parent,varargin{:});
            obj@rt_input(parent,varargin{:});
            
%             pars = inputParser;
%             pars.KeepUnmatched=true;
%             addParameter(pars,'system_output_type','not specified yet');
%             parse(pars,varargin{:});
            obj.fullname='audio synchronous in/output';
            pre_init(obj);  % add the parameter gui
%             add(obj.p,param_generic('system_output_type',pars.Results.system_output_type));
            
            obj.output_drain_type='mic_speaker'; % I am both mic and speaker
            obj.input_source_type='mic_speaker'; % I am both mic and speaker
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_output(obj);
            post_init@rt_input(obj);
            close(obj);
            obj.playerrecorder =  audioPlayerRecorder('SampleRate',obj.parent.SampleRate);
            
%             switch obj.parent.channels
%                 case 'mono'
%                     setup(obj.playerrecorder,zeros(obj.parent.frame_length,1));
%                 case 'stereo'
%                     setup(obj.playerrecorder,zeros(obj.parent.frame_length,2));
%             end
            obj.previous_in=zeros(obj.parent.FrameLength,1);
        end
        
        function sig=read_next(obj)  % rather than using the microphone, we just return the previously saved input buffer
            sig=obj.previous_in(:);
            sig=input_calibrate(obj,sig);
        end
        
        function write_next(obj,sig)  % in the writing cycle, we also get the next input buffer for free
            sig=output_calibrate(obj,sig);
            sig2 = obj.playerrecorder(sig);
            obj.previous_in=sig2; % just save it, ready for play!
        end
        
        function close(obj)
            if ~isempty(obj.playerrecorder) % first release the old one
                release(obj.playerrecorder);
            end
        end
    end
end
