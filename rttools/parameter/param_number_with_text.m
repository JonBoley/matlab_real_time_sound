%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% parameter with one number that effects another number or string to the
% right of it

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef param_number_with_text < param_number
    properties (SetAccess = protected)
        value2;
    end
    
    methods (Access = public)
        
        function param=param_number_with_text(text,val)
            param@param_number(text,val);
            param.value=string(val{1});
            param.value2=string(val{2});
            
        end
        
        function sizedraw=get_draw_size(param,panel)
            sizedraw=get_draw_size@parameter(param,panel);
            sizetext=get_text_size(param,panel);
            sizedraw(1)=sizetext(1)+param.width_element2+param.width_element3; % how wide every element is
        end
        
        
        function setvalue(param,v)  % set the value of this param
            param.value=v{1};
            param.value2=v{2};
            if param.hand(2)>0 && ishandle(param.hand(2))
                set(param.hand(2),'Value',string(param.value));
                set(param.hand(3),'Text',string(param.value2));
            end
            param.is_changed=1;
            
        end
        
        function draw(param,parentpanel,x,y)
            draw@param_number(param,parentpanel,x,y);
%             callbackfct=@(src,event)callback_change_value(param);
            [~,~,elem3]=getelementpositions(param,parentpanel,x,y);
            
            ef2=uilabel(parentpanel);      %  edit box
            ef2.BackgroundColor=[0.94 0.94 0.94];
            ef2.Position=[elem3.x elem3.y elem3.w elem3.h];
            ef2.Text=string(param.value2);
            ef2.FontSize=14;
            ef2.HorizontalAlignment='left';
            param.hand(3) = ef2;
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',{%f,''%s''}',param.text,v,param.value2);
        end
        
%         function disp(param)
%             fprintf('%s (number with text): %d\n',param.text,str2double(param.value));
%         end
%         
% %         function ret=getparamsasstring(param,str)
% %             ret=sprintf('add(%s,param_number_with_text(''%s'',{%f, ''%s''}));',str,str,param.text,str2double(param.value),param.value2);
% %         end
%         
%         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
%             ret=sprintf('setvalue(%s,''%s'', {%f, ''%s''});',str,param.text,param.value,param.value2);
%         end
        
    end
end
