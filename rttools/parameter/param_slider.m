%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% small slider
classdef param_slider < param_float
    properties (SetAccess = protected)
        scale_from_slider;
        scale_to_slider
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods (Access = public)
        
        function param=param_slider(text,val,varargin)
            param@param_float(text,val,varargin{:});
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'minvalue',0);
            addParameter(pars,'maxvalue',1);
            addParameter(pars,'scale','linear');
            parse(pars,varargin{:});
            
            param.minvalue=pars.Results.minvalue;
            param.maxvalue=pars.Results.maxvalue;
            sscale=pars.Results.scale;
            if isequal(sscale,'linear')
                param.scale_from_slider='linlin';
                param.scale_to_slider='linlin';
            elseif isequal(sscale,'log')
                param.scale_from_slider='linlog';
                param.scale_to_slider='loglin';
            else
                disp('wrong scaling in slider')
            end
        end
        
        function size=get_draw_size(param,panel)
            get_draw_size@parameter(param,panel);
            sitext=get_text_size(param,panel);
            size(1)=sitext(1)+param.width_element2+param.width_element3; % how wide every element is
            size(2)=param.unit_scaley;
        end
        
        function param=setvalue(param,val)  % get the value of this param
            param.value=val;
            if param.hand(1)>0 && ishandle(param.hand(2))
                val=f2f(param.value,param.minvalue,param.maxvalue,0,1,param.scale_to_slider); % translate to the scaled value
                set(param.hand(2),'Value',val);  % slider
                set(param.hand(3),'Value',string(param.value)); % edit
            end
            param.is_changed=1;
            if ~isempty(param.callback_function)
                eval(param.callback_function);
            end
        end
        
        function param=callback_change_value2(param) % change slider
            val=get(param.hand(2),'Value');
            val=f2f(val,0,1,param.minvalue,param.maxvalue,param.scale_from_slider); % translate to the scaled value
            param=setvalue(param,val);
        end
        
        function callback_change_value3(param)  % change value edit
            val=str2double(get(param.hand(3),'Value'));
            param=setvalue(param,val);
        end
        
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            [~,elem2,elem3]=getelementpositions(param,parentpanel,x,y);
            callbackfct2=@(src,event)callback_change_value2(param); % slider
            callbackfct3=@(src,event)callback_change_value3(param); % edit
            es = uislider(parentpanel);
            es.Position(1:3)=[elem2.x elem2.y+5 elem2.w ];
            es.ValueChangedFcn=callbackfct2;
            es.Limits=[0 1];
            es.Value=f2f(param.value,param.minvalue,param.maxvalue,0,1,param.scale_to_slider);
            es.FontSize=14;
            es.MajorTicks=[];
            es.MinorTicks=[];
            param.hand(2) = es;
            
            ef=uieditfield(parentpanel);      %  edit box
            ef.BackgroundColor=[1 1 1];
            ef.Position=[elem3.x elem3.y elem3.w elem3.h];
            ef.ValueChangedFcn=callbackfct3;
            ef.Value=string(param.value);
            ef.FontSize=14;
            ef.HorizontalAlignment='right';
            param.hand(3) = ef;
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%f',param.text,v);
        end
    end
end
