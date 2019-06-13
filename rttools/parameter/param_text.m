%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% read only text class: just for info in element2
classdef param_text < parameter
    properties (SetAccess = protected)
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods (Access = public)
        
        function param=param_text(text,val)
            param@parameter(text,val);
            param.value=string(val);
        end
        
        
        function setvalue(param,v)  % set the value of this param
            param.value=v;
            if param.hand(1)>0 && ishandle(param.hand(2))
                set(param.hand(2),'Text',string(param.value));
            end
        end
        
        % draw puts in on the screen. The base class put's on a text and
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            [~,elem2]=getelementpositions(param,parentpanel,x,y);
            
            ut=uilabel(parentpanel);
            ut.BackgroundColor=[0.94 0.94 0.94];
            ut.Position=[elem2.x elem2.y elem2.w elem2.h];
            ut.Text=param.value;
            ut.FontSize=14;
            ut.HorizontalAlignment='left';
            param.hand(2)=ut;
        end
        
%         
%         function disp(param)
%             fprintf('%s (text): %f\n',param.text,param.value);
%         end
%         
%         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
%             ret=sprintf('setvalue(%s,''%s'',%f);',str,param.text,param.value);
%         end
%         
    end
end
