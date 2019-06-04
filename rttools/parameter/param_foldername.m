
classdef param_foldername < param_filename
    properties (SetAccess = protected)
    end
    
    methods (Access = public)
        
        function param=param_foldername(text,val,varargin)
            param@param_filename(text,val);
        end
        
        function select_callback(param)
            nam=uigetdir('.','select a folder');
            if ~isequal(nam,0)
                setvalue(param,nam);
            end
            set_changed_status(param.parent,1);
            param.is_changed=1;
            
        end
        
        function s=get_value_string(param)
            v=getvalue(param);
            s = sprintf('''%s'',''%s''',param.text,v);
        end
        
        function disp(param)
            s=get_value_string(param);
            fprintf('%s\n',s);
        end
        
        
    end    
end