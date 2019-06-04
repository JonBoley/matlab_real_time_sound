


classdef unit_frequency_ms <unit
    properties
    end
    
    methods
        function u=unit_frequency_ms
            u@unit('msec','milliseconds',unitconvertermultpow(0.001,-1));
        end
    end
end








% 
% 
% function nu=unit_frequency_ms
% 
% str.name='ms';
% str.fullname='milli seconds';
% 
% str.converter=unitconvertermultpow(0.001,-1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_frequency_ms',un);