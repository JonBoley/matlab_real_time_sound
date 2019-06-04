
classdef param_button < parameter
    properties (SetAccess = protected)
        button_callback_function;
        button_text;
        button_target=[]; % can be set to modify specific objects in other contexts
    end
    
    methods (Access = public)
        
        function param=param_button(text,varargin)
            param@parameter(text,0,varargin{:});
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'button_callback_function',[]);
            addParameter(pars,'button_text','button');
            addParameter(pars,'button_target',[]);
            parse(pars,varargin{:});
            param.button_callback_function=pars.Results.button_callback_function;
            param.button_target=pars.Results.button_target;
            param.button_text=pars.Results.button_text;
        end
        
        function button_callback_fct(param)
            eval(param.button_callback_function);
        end
        
        function size=get_draw_size(param,panel)
            size= get_draw_size@parameter(param,panel);
            size(1)=size(1)+param.width_element3; % how wide every element is
        end
        
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            [~,~,elem3]=getelementpositions(param,parentpanel,x,y);
            eb=uibutton(parentpanel);      %  edit box
            eb.BackgroundColor=[0.9 0.9 0.9];
            eb.Position=[elem3.x elem3.y elem3.w elem3.h];
            callbackfct=@(src,event)button_callback_fct(param);
            eb.ButtonPushedFcn =callbackfct;
            eb.FontSize=14;
            eb.Text=param.button_text;
            param.hand(3) = eb;
        end
        
        function disp(param)
            fprintf('%s (button): ''%s''\n',param.text,param.button_text);
        end
        
        function ret= get_value_string(param) % return lines like 'setvalue(obj,'what','what')
            ret=''; % buttons can't be set a value
        end
        
    end
end