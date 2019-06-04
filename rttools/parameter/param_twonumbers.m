
classdef param_twonumbers < param_number
    properties (SetAccess = protected)
        value2;
    end
    
    methods (Access = public)
        
        function param=param_twonumbers(text,val,varargin)
            param@param_number(text,val,varargin{:});
            param.value=string(val(1));
            param.value2=string(val(2));
        end
        
        function sizedraw=get_draw_size(param,panel)
            sizedraw=get_draw_size@parameter(param,panel);
            sizetext=get_text_size(param,panel);
            sizedraw(1)=sizetext(1)+param.width_element3; % how wide every element is
        end
        
        function v=getvalue(param)  % get the value of this param
            if isnumeric(param.value)
                v(1)=param.value;
                v(2)=param.value2;
            else
                v(1)=str2double(param.value);
                v(2)=str2double(param.value2);
            end
        end
        
        function callback_change_value2(param)
            param.value2=get(param.hand(3),'Value');
            param.is_changed=1;
            eval(param.callback_function); % and tell the rest of the world, if they are listening
        end
        
        function setvalue(param,v)  % set the value of this param
            param.value=v(1);
            param.value2=v(2);
            if param.hand(1)>0
                set(param.hand(2),'Value',string(param.value));
                set(param.hand(3),'Value',string(param.value2));
            end
            param.is_changed=1;
        end
        
        function draw(param,parentpanel,x,y)
            draw@param_number(param,parentpanel,x,y);
            [~,~,elem3]=getelementpositions(param,parentpanel,x,y);
            
            callbackfct2=@(src,event)callback_change_value2(param);
            ef2=uieditfield(parentpanel);      %  edit box
            ef2.BackgroundColor=[1 1 1];
            ef2.Position=[elem3.x elem3.y elem3.w elem3.h];
            ef2.ValueChangedFcn=callbackfct2;
            ef2.Value=string(param.value2);
            ef2.FontSize=14;
            ef2.HorizontalAlignment='right';
            param.hand(3) = ef2;
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',[%f,%f]',param.text,v(1),v(2));
        end
        
        %         function disp(param)
        %             v=getvalue(param);
        %             fprintf('%s (two numbers): %f,%f\n',param.text,v(1),v(2));
        %         end
        
        %         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
        %             v=getvalue(param);
        %             ret=sprintf('setvalue(%s,''%s'',[%f,%f]);',str,param.text,v(1),v(2));
        %         end
    end
end