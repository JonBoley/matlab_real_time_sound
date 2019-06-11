%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)





classdef unit_frequency_khz <unit
    properties
    end
    
    methods
        function u=unit_frequency_khz
            u@unit('KHz','kilo Herz',unitconvertermultpow(1000,1));
        end
    end
end






% 
% function nu=unit_frequency_khz
% 
% str.name='KHz';
% str.fullname='kilo Herz';
% 
% str.converter=unitconvertermultpow(1000,1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_frequency_khz',un);