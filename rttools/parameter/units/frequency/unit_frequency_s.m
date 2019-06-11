%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef unit_frequency_s <unit
    properties
    end
    
    methods
        function u=unit_frequency_s
            u@unit('sec','seconds',unitconvertermultpow(1,-1));
        end
    end
end




% 
% 
% 
% function nu=unit_frequency_s()
% 
% str.name='s';
% str.fullname='seconds';
% 
% str.converter=unitconvertermultpow(1,-1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_frequency_s',un);