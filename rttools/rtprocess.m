

% class that deals with rt modules. rt processes can do all that modules
% can, but also for n channels and overlap and add/

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef rtprocess < handle
    properties
        parent;  % the object that deals with the data in and out
        basic_module;
        modules; % a list of all modules that need to be executed in this process
        viz_panel; % every process has it's own viz panel and meas panel
        meas_panel;
        % a process can only be one of the following
          is_measurement=0;
        is_manipulation=0;
        is_visualization=0;
        is_input=0;
        is_output=0;
    end
    
    methods
        %% called the first time around to create a process from a module
        function obj=rtprocess(parent,mod)
            obj.parent=parent;
            obj.basic_module=mod; % important, save for later
            obj.basic_module.parent=parent;
            obj.modules=[]; % the actual object(s)
        end
        
        function initialize(obj)
            % default version only has one module
            post_init(obj.basic_module);
        end
        
        function close(obj)
            % default version only has one module
            close(obj.basic_module);
        end
        
%         function  ss=get_as_script_string(obj,oname)
%             % returns the obj in a form that it can be initialized in a
%             % script. including all parameters in the right form
%             ss=get_as_script_string(obj.basic_module,oname);
%         end
        
    end
end
