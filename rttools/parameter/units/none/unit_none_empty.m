%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef unit_none_empty < unit
    properties
    end
    
    methods
        function u=unit_none_empty
            u@unit(' ','no unit',unitconvertermultpow(1,1));
            
        end
    end
end



% 
% 
% 
% function nu=unit_none_empty
% 
% str.name='';
% str.fullname='no unit';
% 
% str.converter=unitconvertermultpow(1,1);;
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_none_empty',un);