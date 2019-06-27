%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)





classdef unit_mod < unitbag
    properties
    end
    
    methods
        function u=unit_mod
            u@unitbag('modulation depth');
            u=add(u,unit_mod_lin);
            u=add(u,unit_mod_perc);
            u=add(u,unit_mod_db);
        end
        function s=getname(obj)
            s='unit_mod';
        end
    end
end




%
%
%
% function unitobj=unit_mod
%
% str.name='modulation depth';
% ub=unitbag(str.name);
% ub=add(ub,unit_mod_lin);
% ub=add(ub,unit_mod_perc);
% ub=add(ub,unit_mod_db);
% ub=add(ub,unit_mod_db_atten);
% ub=add(ub,unit_mod_maxtomin);
%
%
%
% unitobj= class(str,'unit_mod',ub);

%   Copyright 2019 Stefan Bleeck, University of Southampton



