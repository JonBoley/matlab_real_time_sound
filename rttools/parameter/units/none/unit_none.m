%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef unit_none < unitbag
    properties
    end
    
    methods
        function u=unit_none
            u@unitbag('no unit');
            u=add(u,unit_none_empty);

        end
        
        function s=getname(obj)
            s='unit_none';
        end
    end
end



% end
%
% function unitobj=unit_none
%
% str.name='no unit';
% ub=unitbag(str.name);
% ub=add(ub,unit_none_empty);
%
% unitobj= class(str,'unit_none',ub);

%   Copyright 2019 Stefan Bleeck, University of Southampton

