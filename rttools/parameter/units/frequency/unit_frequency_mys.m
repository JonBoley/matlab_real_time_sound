%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef unit_frequency_mys <unit
    properties
    end
    
    methods
        function u=unit_frequency_mys
            u@unit('µsec','microseconds',unitconvertermultpow(0.000001,-1));
        end
    end
end
% 
% 
% 
% 
% 
% 
% 
% 
% function nu=unit_frequency_mys()
% 
% str.name='µs';
% str.fullname='micro seconds';
% 
% str.converter=unitconvertermultpow(0.000001,-1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_frequency_mys',un);