%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef unit_frequency_hz <unit
    properties
    end
    
    methods
        function u=unit_frequency_hz
            u@unit('Hz','Herz',unitconvertermultpow(1,1));
        end
    end
end




% 
% 
% function nu=unit_frequency_hz
% 
% str.name='Hz';
% str.fullname='Herz';
% 
% str.converter=unitconvertermultpow(1,1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_frequency_hz',un);