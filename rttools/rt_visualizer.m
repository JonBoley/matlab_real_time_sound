

classdef rt_visualizer < rt_module
    properties
        viz_axes;
        viz_panel;
    end
    
    methods
        function obj=rt_visualizer(parent,varargin)
            obj@rt_module(parent,varargin{:});
            obj.is_visualization=1;
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_module(obj);
            if ~isempty(obj.viz_panel)
                p=obj.viz_panel.InnerPosition;
                obj.viz_axes=uiaxes(obj.viz_panel,'Position',[1 1 p(3)-2 p(4)-2]);
                cla(obj.viz_axes,'reset');
            else
                obj.viz_axes=[]; % indicate that we don't want to see anything
            end
        end
    end
end

