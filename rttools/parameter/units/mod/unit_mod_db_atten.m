%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unit_mod_db_atten < unit
    properties
    end
    
    methods
        function u=unit_mod_db_atten
            u@unit('dB atten','dB atten',unitconverterlogvneg);
            
        end
    end
end
% 
% function nu=unit_mod_db_atten
% 
% str.name='dB atten';
% str.fullname='dB atten';
% 
% str.converter=unitconverterlogvneg;
% 
% un=unit(str.name,str.fullname,str.converter);
% nu=class(str,'unit_mod_db_atten',un);