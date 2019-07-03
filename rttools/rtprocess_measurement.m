%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef rtprocess_measurement < rtprocess
    properties
    end
    
    methods
        %% called the first time around to create a process from a modules
        function obj=rtprocess_measurement(parent,mod)
            obj@rtprocess(parent,mod);
            % a process can only be one of the following
            obj.is_measurement=1;
        end
        
        function obj=initialize(obj)
            pan=obj.meas_panel;
            if ~isempty(pan)
                axsize=pan.Position;
                x1=1;
                y1=1;
                w1=axsize(3)-1;
                h1=axsize(4)-20;
                obj.basic_module.measurement_axis = uiaxes(pan,'Position',[x1 y1,w1,h1]); % one axis full size
            else
                obj.basic_module.measurement_axis =[]; % leave empty, I don't want to see the graph, just give me back the result of the measurement
            end
            post_init(obj.basic_module);
            obj.modules=obj.basic_module;
        end
        
        function obj=process(obj)
            obj.parent.measurement_result{obj.parent.frame_counter}=calculate(obj.modules,obj.parent.current_stim);
        end
    end
end
