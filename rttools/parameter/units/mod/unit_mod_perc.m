%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unit_mod_perc < unit
    properties
    end
    
    methods
        function u=unit_mod_perc
            u@unit('%','percent',unitconvertermultpow(0.01,1));
            
        end
    end
end
% 
% function nu=unit_mod_perc
% 
% str.name='%';
% str.fullname='percent';
% 
% str.converter=unitconvertermultpow(0.01,1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_mod_perc',un);