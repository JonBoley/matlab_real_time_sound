
% classdef param_popupmenu_with_button < param_popupmenu & param_button

%   Copyright 2019 Stefan Bleeck, University of Southampton

classdef param_popupmenu_with_button < param_popupmenu & param_button

    methods (Access = public)
        
        function param=param_popupmenu_with_button(text,val,varargin)
            param@param_button(text,varargin{:});
            param@param_popupmenu(text,val,varargin{:});
        end
        
        function size=get_draw_size(param,panel)
            size=get_draw_size@parameter(param,panel);
            size(1)=size(1)+param.width_element3; % how wide every element is
        end
        
        function draw(param,parentpanel,x,y)
            draw@param_popupmenu(param,parentpanel,x,y);
            draw@param_button(param,parentpanel,x,y);
            callbackfct=@(src,event)button_callback_fct(param);
            set(param.hand(3),'ButtonPushedFcn',callbackfct);
        end
        
%         function ret=getparamsasstring(param,str)
%             mlist='{';
%             mlist=[mlist sprintf('''%s''',param.list{1})];
%             for i=2:length(param.list)
%                 mlist=[mlist sprintf(';''%s''',param.list{i})];
%             end
%             mlist=[mlist,'}'];
%             ret=sprintf('add(%s,param_popupmenu(''%s'',''%s'',''list'',%s));',str,str,param.text,param.value,mlist);
%         end

%         function disp(param)
%             fprintf('%s (popup_with_button): %s\n',param.text,param.value);
%         end
%         
%         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
%             ret=sprintf('setvalue(%s,''%s'',''%s'');',str,param.text,param.value);
%         end        
    end
end
