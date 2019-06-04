
classdef param_number < parameter
    properties (SetAccess = protected)
    end
    
    methods (Access = public)
        
        function param=param_number(text,val,varargin)
            param@parameter(text,val,varargin{:});
            param.value=string(val);
        end
        function v=getvalue(param)  % get the value of this param
            v=param.value;
            if ischar(v) ||isstring(v)
                v=str2double(v);
            end
        end
        
        function setvalue(param,v)  % set the value of this param
            param.value=v;
            if param.hand(1)>0
                set(param.hand(2),'Value',string(param.value));
            end
            param.is_changed=1;
        end
        
        % draw puts in on the screen. The base class put's on a text and
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            callbackfct=@(src,event)callback_change_value(param);
            [~,elem2]=getelementpositions(param,parentpanel,x,y);
            
            ef=uieditfield(parentpanel);      %  edit box
            ef.BackgroundColor=[1 1 1];
            ef.Position=[elem2.x elem2.y elem2.w elem2.h];
            ef.ValueChangedFcn=callbackfct;
            ef.Value=string(param.value);
            ef.FontSize=14;
            ef.HorizontalAlignment='right';
            param.hand(2) = ef;
        end
        
          function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%f',param.text,v);
        end
        
%         
%         function disp(param)
%             fprintf('%s (number): %f\n',param.text,param.value);
%         end
%         
% %         function ret=getparamsasstring(param,str)
% %             ret=sprintf('add(%s,param_number(''%s'',%f));',str,str,param.text,param.value);
% %         end
%         
%         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
%             ret=sprintf('setvalue(%s,''%s'',%f);',str,param.text,param.value);
%         end
        
%   Copyright 2019 Stefan Bleeck, University of Southampton
        
    end
end
