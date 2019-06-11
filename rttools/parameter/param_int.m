%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef param_int <  param_number
    properties (SetAccess = protected)
    end
    
    methods (Access = public)
        
        function param=param_int(text,val,varargin)
            param@param_number(text,val,varargin{:});
            param.value=string(val);
        end
        function v=getvalue(param)  % get the value of this param
            v=param.value;
            if ischar(v) ||isstring(v)
                v=str2double(v);
            end
            v=round(v);
        end
        
        function setvalue(param,v)  % set the value of this param
            param.value=round(v);
            if param.hand(1)>0 && ishandle(param.hand(2))
                set(param.hand(2),'Value',string(param.value));
            end
            param.is_changed=1;
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            v=getvalue(param);
            s = sprintf('''%s'',%d',param.text,round(v));
        end
        
    end
end