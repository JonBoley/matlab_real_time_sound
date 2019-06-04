
classdef param_popupmenu < parameter
    properties (SetAccess = protected)
        list;
    end
    
    methods (Access = public)
        
        function param=param_popupmenu(text,val,varargin)
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'list',[]);
            parse(pars,varargin{:});
            param@parameter(text,val);
            param.value=val;
            param.list=pars.Results.list;
        end
        
        function setvalue(param,val)  % get the value of this param
            for i=1:length(param.list)
                if isequal(param.list{i},val)
                    param.value=val;
                    if param.hand(1)>0
                        set(param.hand(2),'Value',val);
                    end
                    param.is_changed=1;
                    return
                end
            end
            error('''%s'' is not in the list in parameter ''%s''\n',val,param.text);
        end
        
        function nr=get_select_number(param)
            val=param.value;
            for i=1:length(param.list)
                if isequal(param.list{i},val)
                    nr=i;
                end
            end
        end
        
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            callbackfct=@(src,event)callback_change_value(param);
            [~,elem2]=getelementpositions(param,parentpanel,x,y);
            ed=uidropdown(parentpanel);      %  edit box
            ed.BackgroundColor=[1 1 1];
            ed.Position=[elem2.x elem2.y elem2.w elem2.h];
            ed.ValueChangedFcn=callbackfct;
            ed.Items=param.list;
            ed.Value=string(param.value);
            ed.FontSize=14;
            param.hand(2) = ed;
        end
    end
end