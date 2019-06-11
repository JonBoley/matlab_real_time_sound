%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef unitconverterlogvneg < unitconverter
    properties
        
    end
    methods
        function un=unitconverterlogvneg(mult,powr)
            un@unitconverter('for converting between a POWER ratio and a negative DB POWER ratio');
        end
        
        
        function val=tounits(un,valold)
            val=-20*log10(valold);
        end
        function newval=fromunits(un,oldval)
            newval=power(10,(-oldval/20));
        end
        
    end
end
