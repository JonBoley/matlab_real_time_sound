
classdef unitbag
    properties
        name;
        units
    end
    methods
        function ub=unitbag(name)
            ub.name=name;    % the name of the unit
            ub.units=[];%containers.Map;
        end
        
        function newval=tounit(ub,val,name)
            nr=findunitnr(ub,name);
            newval=tounits(ub.units{nr},val);
        end
        
        function newval=fromunit(ub,val,name)  % return raw value (base unit) from val
            
            nr=findunitnr(ub,name);
            newval=fromunits(ub.units{nr},val);
            
        end
        
        function nr=findunitnr(ub,name)
            nr_un=length(ub.units);
            nr=-1;
            for i=1:nr_un
                if isequal(ub.units{i}.name,name)
                    nr=i;
                    return
                end
            end
            fprintf('fromunit: requested unit ''%s'' does not exist in ''%s''. Available:\n',name,ub.name)
            ret1=getunitsstrings(ub);ret2=getunitsfullstrings(ub);
            for i=1:length(ret1)
                fprintf('%s (%s)\n',ret1{i},ret2{i});
            end
        end
        
        
        function ret=getunitsstrings(ub)
            for i=1:length(ub.units)
                ret{i}=ub.units{i}.name;
            end
        end
        function ret=getunitsfullstrings(ub)
            for i=1:length(ub.units)
                ret{i}=ub.units{i}.fullname;
            end
        end
        
        function nr=findunit(ub,unitname)
            % returns the number of the unitname in the unitbag ub
            for i=1:length(ub.units)
                unname=getname(ub.units{i});
                if strcmp(unname,unitname)
                    nr=i;
                    return
                end
            end
        end
        function ub=add(ub,new)
            nr_a=length(ub.units);
            ub.units{nr_a+1}=new;
        end
        
    end
end
