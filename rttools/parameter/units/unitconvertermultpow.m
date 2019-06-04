
classdef unitconvertermultpow < unitconverter
    properties
        multiplier;
        powerval;
    end
    methods
        function un=unitconvertermultpow(mult,powr)
            un@unitconverter('mult and power');
            un.multiplier=mult;
            un.powerval=powr;
        end
        
        
        function newval=tounits(un,oldval)
            mlt=un.multiplier;
            pwr=un.powerval;
            newval=power(oldval,pwr)/mlt;
        end
        function newval=fromunits(un,oldval)
            mlt=un.multiplier;
            pwr=un.powerval;
            newval=power(oldval*mlt,pwr);
        end
        
    end
end