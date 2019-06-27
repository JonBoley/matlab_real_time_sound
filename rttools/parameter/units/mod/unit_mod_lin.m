%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unit_mod_lin < unit
    properties
    end
    
    methods
        function u=unit_mod_lin
            u@unit('lin','linear',unitconvertermultpow(1,1));
        end
    end
end
% 
% 
% function nu=unit_mod_lin
% 
% str.name='lin';
% str.fullname='linear';
% 
% str.converter=unitconvertermultpow(1,1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_mod_lin',un);