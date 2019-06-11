%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


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
            
            % no need for translation from panel to axis, as there is
            % always only one measurement axis. 
            % 
%             if ~isempty(obj.meas_panel)
%                 p=obj.meas_panel.InnerPosition;
%                 obj.measurement_axis=uiaxes(obj.meas_panel,'Position',[1 1 p(3)-2 p(4)-2]);
%                 cla(obj.measurement_axis,'reset');
%             else
%                 obj.meas_panel=[]; % indicate that we don't want to see anything
%             end
        end
        
        
        function result=calculate(obj,sig)
            result=-1;
        end
        
        function t=wait_time(obj)
            t=obj.parent.global_time-obj.measuring_start_time;
        end
        
    end
end

