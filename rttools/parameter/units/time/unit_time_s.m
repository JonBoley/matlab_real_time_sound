%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unit_time_s < unit
    properties
    end
    
    methods
        function u=unit_time_s
            u@unit('sec','seconds',unitconvertermultpow(1,1));
            
        end
    end
end
% 
% function nu=unit_time_s()
% 
% str.name='s';
% str.fullname='seconds';
% 
% str.converter=unitconvertermultpow(1,1);
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_time_s',un);