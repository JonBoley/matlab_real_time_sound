%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef unit
    properties
        name;
        fullname;
        converter;
    end
    methods
        function un=unit(name,fullname,converter)
            un.name=name;
            un.fullname=fullname;
            un.converter=converter;
        end
        
        function val=tounits(un,valold)
            val=tounits(un.converter,valold);
        end
        
        function newval=fromunits(un,oldval)
            newval=fromunits(un.converter,oldval);
        end     
    end
end
