


classdef rt_measurer < rt_module
    properties
        measurement_axis;
        measuring_start_time; % many measurer want to wait for a second, because they don't work on zero input
    end
    
    methods
        function obj=rt_measurer(parent,varargin) %% called the very first time around
            obj@rt_module(parent,varargin{:});
            obj.is_measurement=1;
        end
        
        function obj=post_init(obj) % called the second times around
            post_init@rt_module(obj);
        end
        
        function result=calculate(obj,sig)
            result=-1;
        end
        
        function t=wait_time(obj)
            t=obj.parent.global_time-obj.measuring_start_time;
        end
        
        
    end    
end

