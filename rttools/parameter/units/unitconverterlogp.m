
classdef unitconverterlogp < unitconverter
    properties
        
    end
    methods
        function un=unitconverterlogp(mult,powr)
            un@unitconverter('for converting between a POWER ratio and a DB POWER ratio');
        end
        
        
        function val=tounits(un,valold)
            val=10*log10(valold);
        end
        function newval=fromunits(un,oldval)
            val=power(10,(oldval/10));
        end
        
    end
end