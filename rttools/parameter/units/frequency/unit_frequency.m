%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef unit_frequency < unitbag
    properties
    end
    
    methods
        function u=unit_frequency
            u@unitbag('frequency');
            u=add(u,unit_frequency_hz);
            u=add(u,unit_frequency_khz);
            u=add(u,unit_frequency_s);
            u=add(u,unit_frequency_ms);
            u=add(u,unit_frequency_mys);
        end
        
                function s=getname(obj)
            s='unit_frequency';
        end
    end
end

% 
% 
% function unitobj=unit_frequency
% 
% str.name='frequency';
% ub=unitbag(str.name);
% ub=add(ub,unit_frequency_hz);
% ub=add(ub,unit_frequency_khz);
% ub=add(ub,unit_frequency_s);
% ub=add(ub,unit_frequency_ms);
% ub=add(ub,unit_frequency_mys);
% 
% 
% unitobj= class(str,'unit_frequency',ub);
% 

%   Copyright 2019 Stefan Bleeck, University of Southampton


