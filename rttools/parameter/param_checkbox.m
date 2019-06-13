%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

%   Copyright 2019 Stefan Bleeck, University of Southampton

classdef param_checkbox < parameter
    
    methods (Access = public)
        function param=param_checkbox(text,val,varargin)
            param@parameter(text,val,varargin{:});
            
        end
        function setvalue(param,v)  % set the value of this param
            param.value=v;
            if param.hand(1)>0 && ishandle(param.hand(2))
                
                 set(param.hand(2),'Value',param.value);
%                 if param.value==1   
%                     set(param.hand(2),'Value','ON');
%                 else
%                     set(param.hand(2),'Value','OFF');
%                 end
            end
            param.is_changed=1;
        end
        
        function size=get_draw_size(param,panel)
            size=get_draw_size@parameter(param,panel);
            size(1)=5*param.unit_scalex; % how wide every element is
        end
        
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            callbackfct=@(src,event)callback_change_value(param);
            [~,elem2]=getelementpositions(param,parentpanel,x,y);
            
            ef=uicheckbox(parentpanel);      %  edit box
            ef.Position=[elem2.x elem2.y elem2.w elem2.h];
            ef.ValueChangedFcn=callbackfct;
            ef.Value=param.value;
            ef.Text='';
            param.hand(2) = ef;
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%d',param.text,v);
        end
    end
end
