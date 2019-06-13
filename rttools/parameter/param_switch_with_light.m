%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef param_switch_with_light < param_checkbox
    properties (SetAccess = protected)
        myswitch;
        mylamp;
    end
    
    methods (Access = public)
        function param=param_switch_with_light(text,val,varargin)
            param@param_checkbox(text,val,varargin{:});
        end
        
        function setvalue(param,v)  % set the value of this param
            param.value=v;
            if param.hand(1)>0 && ishandle(param.hand(2))
                
                if param.value==1
                    set(param.hand(2),'Value','ON');
                    param.mylamp.Color='green';
                    
                else
                    set(param.hand(2),'Value','OFF');
                    param.mylamp.Color='red';
                    
                end
            end
            
            param.is_changed=1;
        end
        
        function size=get_draw_size(param,panel)
            size= get_draw_size@param_checkbox(param,panel);
            size(1)=size(1)+param.width_element3; % how wide every element is
        end
        
        function switch_callback_function(param)
            if isequal(param.myswitch.Value,'ON')
                param.mylamp.Color='green';
                param.value=1;
            else
                param.mylamp.Color='red';
                param.value=0;
            end
            eval(param.callback_function);
        end
        
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y); % draw the text
            
            callbackfct1=@(src,event)switch_callback_function(param);
            
            [~,elem2,elem3]=getelementpositions(param,parentpanel,x,y);
            
            param.myswitch = uiswitch(parentpanel);
            param.myswitch.Items = {'ON','OFF'};
            param.myswitch.Position=[elem2.x+30 elem2.y elem2.w elem2.h];
            param.myswitch.ValueChangedFcn=callbackfct1;
            param.hand(2) = param.myswitch;
            
            param.mylamp = uilamp(parentpanel);
            param.mylamp.Color = 'green';
            param.mylamp.Position=[elem3.x+30 elem3.y elem3.w elem3.h];
            param.hand(3) = param.mylamp;
            
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%d',param.text,v);
        end
        
        %         function disp(param)
        %             fprintf('%s (switch with light): %d\n',param.text,param.value);
        %         end
        %
        %          function ret=get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
        %             ret=sprintf('setvalue(%s,''%s'',%d);',str,param.text,param.value);
        %          end
        
    end
end