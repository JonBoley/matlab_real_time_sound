


classdef unitconverterlogv < unitconverter
    properties
        
    end
    methods
        function un=unitconverterlogv(mult,powr)
            un@unitconverter('for converting between a POWER ratio and a negative DB POWER ratio');
        end
        
        
        function val=tounits(un,valold)
val=20*log10(valold);        end
        function newval=fromunits(un,oldval)
newval=power(10,(oldval/20));
        end
        
    end
end
