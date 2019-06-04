
% simple class to define that we don't want to be on schreen as selectable
classdef no_show < handle
    methods
        function obj=no_show(obj)
            obj.show=0;
        end
    end
end