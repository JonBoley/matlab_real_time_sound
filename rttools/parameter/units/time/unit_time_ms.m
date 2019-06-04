
classdef unit_time_ms <unit
    properties
    end
    
    methods
        function u=unit_time_ms
            u@unit('msec','milliseconds',unitconvertermultpow(0.001,1));
        end
    end
end
% 
% function nu=unit_time_ms()
% 
% str.name='ms';
% str.fullname='milli seconds';
% 
% str.converter=unitconvertermultpow(0.001,1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_time_ms',un);