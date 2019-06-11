%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef param_float_slider < param_float
    properties (SetAccess = protected)
        width_element4; % slider
        scale_from_slider;
        scale_to_slider
    end
    
    methods (Access = public)
        
        function param=param_float_slider(text,val,varargin)
            param@param_float(text,val,varargin{:});
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'unittype',unit_none);
            addParameter(pars,'unit','');
            addParameter(pars,'minvalue',0);
            addParameter(pars,'maxvalue',1);
            addParameter(pars,'scale','linear');
            parse(pars,varargin{:});
            
            param.minvalue=pars.Results.minvalue;
            param.maxvalue=pars.Results.maxvalue;
            param.unit=pars.Results.unit;
            param.unittype=pars.Results.unittype;
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
            param.width_element4=20*param.unit_scalex; % the slider
            
        end
        function size=get_draw_size(param,panel)
            get_draw_size@parameter(param,panel);
            sitext=get_text_size(param,panel);
            textl=sitext(1)+param.width_element2+param.width_element3; % how wide every element is
            size(1)=max(textl,param.width_element4);
            size(2)=2*param.unit_scaley;
        end
        
        function setvalue(param,val,wantedunit)  % get the value of this param
            if nargin==3
                setvalue@param_float(param,val,wantedunit);
            elseif nargin==2
                setvalue@param_float(param,val);
            end
            
            if param.hand(1)>0 && ishandle(param.hand(2))
                set(param.hand(2),'Value',string(param.value)); % edit
                val=f2f(param.value,param.minvalue,param.maxvalue,0,1,param.scale_to_slider); % translate to the scaled value
                set(param.hand(4),'Value',val);  %slide
            end
            param.is_changed=1;
        end
        
        
        function setunit(param,wantedunit)  % change the unit of the parameter
            setunit@param_float(param,wantedunit);
        end
        
        function callback_change_value1(param)  % change value
            val=str2double(get(param.hand(2),'Value'));
            setvalue(param,val,param.unit);
            param.is_changed=1;
                        eval(param.callback_function); % and tell the rest of the world, if they are listening
        end
        
        function callback_change_value2(param) % change unit AND update value automatically
            sel=get(param.hand(3),'Value');
            setunit(param,sel);
            param.is_changed=1;
                        eval(param.callback_function); % and tell the rest of the world, if they are listening
        end
        
        function callback_change_value3(param) % slider has been changed
            val=get(param.hand(4),'Value');
            val=f2f(val,0,1,param.minvalue,param.maxvalue,param.scale_from_slider); % translate to the scaled value
            setvalue(param,val,param.unit);
            param.is_changed=1;
%             eval(param.callback_function); % and tell the rest of the world, if they are listening
        end
                
        function draw(param,parentpanel,x,y)
            draw@param_float(param,parentpanel,x,y+param.unit_scaley);
            [~,elem2]=getelementpositions(param,parentpanel,x,y);
            
            % position of slider element:
            x4=elem2.x;
            y4=y+10;
            w4=param.width_element4;
            
            callbackfct3=@(src,event)callback_change_value3(param); % slider
            es = uislider(parentpanel);
            es.Position(1:3)=[x4 y4 w4];
            es.ValueChangedFcn=callbackfct3;
            es.Limits=[0 1];  % always! the scaling comes later
            es.Value=f2f(param.value,param.minvalue,param.maxvalue,0,1,param.scale_to_slider);
            es.FontSize=14;
            es.MajorTicks=[];
            es.MinorTicks=[];
            param.hand(4) = es;
        end
        
%         function disp(param)
%             fprintf('%s (param_float_slider): %f\n',param.text,param.value);
%         end
%         %                 function ret=getparamsasstring(param,str)
%         %                     ret=sprintf('add(%s,param_slider(''%s'',%f,''unit'',''%s'',''unittype'',%s,''minvalue'',%f,''maxvalue'',%f))'...
%         %                         ,str,str,param.text,param.value,param.unit,getname(param.unittype),param.minvalue,param.maxvalue);
%         %                 end
%         
%         function ret=get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
%             if isequal(param.unittype,unit_none)
%                 ret=sprintf('setvalue(%s,''%s'',%f);',str,param.text,param.value);
%             else
%                 ret=sprintf('setvalue(%s,''%s'',%f,''%s'');',str,param.text,param.value,param.unit);
%             end
%         end
%         
          function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%f',param.text,v);
          end
        
    end
end
