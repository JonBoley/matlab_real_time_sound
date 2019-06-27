%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unit_mod_db < unit
    properties
    end
    
    methods
        function u=unit_mod_db
            u@unit('dB','dB',unitconverterlogv);
            
        end
    end
end



% 
% function nu=unit_mod_db
% 
% str.name='dB';
% str.fullname='dB';
% 
% str.converter=unitconverterlogv;
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_mod_db',un);