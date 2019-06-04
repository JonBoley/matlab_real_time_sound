
classdef unit_time < unitbag
    properties
    end
    
    methods
        function u=unit_time
            u@unitbag('time');
            u=add(u,unit_time_s);
            u=add(u,unit_time_ms);
            u=add(u,unit_time_hz);
            u=add(u,unit_time_min);
%             u=add(u,unit_time_hours);
%             u=add(u,unit_time_days);
        end
        
%   Copyright 2019 Stefan Bleeck, University of Southampton
        function s=getname(obj)
            s='unit_time';
        end
    end
end




% 
% 
% 
% function unitobj=unit_time
% 
% str.name='time';
% ub=unitbag(str.name);
% ub=add(ub,unit_time_s);
% ub=add(ub,unit_time_ms);
% ub=add(ub,unit_time_mys);
% ub=add(ub,unit_time_hz);
% ub=add(ub,unit_time_min);
% ub=add(ub,unit_time_hours);
% ub=add(ub,unit_time_days);
% ub=add(ub,unit_time_weeks);
% % ub=add(ub,unit_time_months);
% % ub=add(ub,unit_time_years);
% 
% 
% unitobj= class(str,'unit_time',ub);
