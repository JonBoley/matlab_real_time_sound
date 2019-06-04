
classdef unit_time_hz <unit
    properties
    end
    
    methods
        function u=unit_time_hz
            u@unit('Hz','Herz',unitconvertermultpow(1,-1));
        end
    end
end
% function unitobj=unit_time_hz
% 
% str.name='hz';
% str.fullname='herz';
% 
% str.converter=unitconvertermultpow(1,-1);
% 
% un=unit(str.name,str.fullname,str.converter);
% unitobj=class(str,'unit_time_hz',un);

%   Copyright 2019 Stefan Bleeck, University of Southampton


