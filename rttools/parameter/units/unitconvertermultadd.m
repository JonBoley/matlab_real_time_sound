%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unitconvertermultadd < unitconverter
    properties
        multiplier;
        add;
    end
    methods
        function un=unitconvertermultadd(mult,powr)
            un@unitconverter('mult and power');
            un.multiplier=mult;
            un.powerval=powr;
        end
        
        
        function newval=tounits(un,oldval)
            mlt=un.multiplier;
            ad=un.add;
            newval=(oldval*mlt)+ad;
        end
        function newval=fromunits(un,oldval)
            mlt=un.multiplier;
            ad=un.add;
            newval=(oldval-ad)/mlt;
        end
        
    end
end