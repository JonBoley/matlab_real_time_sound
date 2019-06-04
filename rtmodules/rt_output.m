% input module, can return signals
classdef rt_output < rt_module & no_show
    properties
        output_drain_type; % variable to store information what I am, file or microphone
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_output(parent,varargin) %% called the very first time around
            obj@rt_module(parent,varargin{:});
            pre_init(obj);  % add the parameter gui
            obj.is_output=1;
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_module(obj);
        end
        
        function write_next(obj,sig)
        end
        
        function close(obj)
        end
        
        function sig=output_calibrate(obj,sig)
            gain_correct=obj.parent.gain_correct_speaker;
            fac=power(10,gain_correct/20);
            sig=sig.*fac;
        end
        
    end
    
end
