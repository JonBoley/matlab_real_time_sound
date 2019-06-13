%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef param_float < parameter
    properties (SetAccess = public)
        minvalue;
        maxvalue;
        unit;  % the specific unit (e.g. meter)
        unittype;  % the type of unit (e.g. length)
    end
    
    methods (Access = public)
        
        function param=param_float(text,val,varargin)
            param@parameter(text,val,varargin{:});
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'unittype',unit_none);
            addParameter(pars,'unit','');
            addParameter(pars,'minvalue',-inf);
            addParameter(pars,'maxvalue',inf);
            parse(pars,varargin{:});
            
            param.minvalue=pars.Results.minvalue;
            param.maxvalue=pars.Results.maxvalue;
            param.unit=pars.Results.unit;
            param.unittype=pars.Results.unittype;
            
        end
        
        function sizedraw=get_draw_size(param,panel)
            sizedraw=get_draw_size@parameter(param,panel);
            sizetext=get_text_size(param,panel);
            sizedraw(1)=sizetext(1)+param.width_element2+param.width_element3; % how wide every element is
        end
        
        function val=getvalue(param,wantedunit)  % get the value of this param
            val=param.value;
            if nargin<2
                return
            end
            rawvalue=fromunit(param.unittype,param.value,param.unit); % translate to rawdata (data in base unit)
            val=tounit(param.unittype,rawvalue,wantedunit); % translate to asked unit
        end
        
        function setvalue(param,val,wantedunit)  % get the value of this param
            if val>param.maxvalue
                disp('value too large!')
                return
            end
            if val<param.minvalue
                disp('value too small!')
                return
            end
            param.value=val;
            param.is_changed=1;
            
            if nargin<3
            if param.hand(1)>0 && ishandle(param.hand(2))
                    set(param.hand(2),'Value',string(param.value));
                end
                return
            end
            param.unit=wantedunit; % just set it as requested
            
            if param.hand(1)>0
                set(param.hand(2),'Value',string(param.value));
                if ~isequal(param.unittype,unit_none)
                    set(param.hand(3),'Value',param.unit);
                end
            end
        end
        
        function setunit(param,wantedunit)  % change the unit of the parameter
            param.value=getvalue(param,wantedunit);
            param.unit=wantedunit; % just set it as requested
            
            if param.hand(1)>0
                set(param.hand(2),'Value',string(param.value));
                if ~isequal(param.unittype,unit_none)
                    set(param.hand(3),'Value',param.unit);
                end
            end
        end
        
        function callback_change_value1(param)  % change value
            param.value=str2double(get(param.hand(2),'Value'));
            param.is_changed=1;
            eval(param.callback_function); % and tell the rest of the world, if they are listening
        end
        
        function callback_change_value2(param) % change unit AND update value automatically
            sel=get(param.hand(3),'Value');
            setunit(param,sel);
        end
        
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            callbackfct1=@(src,event)callback_change_value1(param);
            callbackfct2=@(src,event)callback_change_value2(param);
            [~,elem2,elem3]=getelementpositions(param,parentpanel,x,y);
            
            ef=uieditfield(parentpanel);      %  edit box
            ef.BackgroundColor=[1 1 1];
            ef.Position=[elem2.x elem2.y elem2.w elem2.h];
            ef.ValueChangedFcn=callbackfct1;
            ef.Value=string(param.value);
            ef.FontSize=14;
            ef.HorizontalAlignment='right';
            param.hand(2) = ef;
            
            if ~isequal(param.unittype,unit_none)
                unitvals=getunitsstrings(param.unittype);
                ed=uidropdown(parentpanel);      %  edit box
                ed.BackgroundColor=[1 1 1];
                ed.Position=[elem3.x elem3.y elem3.w elem3.h];
                ed.ValueChangedFcn=callbackfct2;
                ed.Items=unitvals;
                ed.Value=param.unit;
                ed.FontSize=14;
                param.hand(3) = ed;
            end
        end
        
      
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%f',param.text,v);
        end
        
    end
end