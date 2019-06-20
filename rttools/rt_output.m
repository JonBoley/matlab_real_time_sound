%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_output < rt_module
    properties
        output_drain_type; % variable to store information what I am, file or microphone
    end
    
    methods
        function obj=rt_output(parent,varargin) %% called the very first time around
            obj@rt_module(parent,varargin{:});
            pre_init(obj);  % add the parameter gui
            obj.is_output=1;
%             obj.show=0; % don't show me to the user
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_module(obj);
        end
        
        
        function close(obj)
        end
        
        % null function for calibration: do nothing
        function sig=calibrate_out(obj,sig)
            sig=sig;
%             [outgain,outcalib]=get_output_calib(obj.parent,obj);
%             fac=power(10,(outgain+outcalib)/20);
%             sig=sig.*fac;
        end
        
    end
    
end
