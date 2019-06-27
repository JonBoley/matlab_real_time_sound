%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef param_number_with_button < param_number & param_button
    methods (Access = public)
        function param=param_number_with_button(text,val,varargin)
            param@param_button(text,varargin{:});
            param@param_number(text,val,varargin{:});
        end
        
        function size=get_draw_size(param,panel)
            size= get_draw_size@param_number(param,panel);
            size(1)=size(1)+param.width_element2+length(param.button_text)*8; % how wide every element is
        end
        
        function draw(param,parentpanel,x,y)
            draw@param_number(param,parentpanel,x,y);
            draw@param_button(param,parentpanel,x,y);
            callbackfct=@(src,event)button_callback_fct(param);
            set(param.hand(3),'ButtonPushedFcn',callbackfct);
        end
        
        function disp(param)
            fprintf('%s (number with button): %d\n',param.text,param.value);
        end
        
%         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
%             ret=sprintf('setvalue(%s,''%s'',%d);',str,param.text,param.value);
%         end
%         
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%f,%d',param.text,v);
        end
        
        %         function ret=getparamsasstring(param,str)
        %             ret=sprintf('add(%s,param_checkbox_with_button(''%s'',%d,''callback_function'',''%s'',''button_text'',''%s''));',...
        %                 str,str,param.text,param.value,...
        %                 param.callback_function,param.button_text);
        %         end
    end
end