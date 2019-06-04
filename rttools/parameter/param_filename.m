
classdef param_filename < param_generic & param_button
    
    methods (Access = public)
        function param=param_filename(text,val,varargin)
            param@param_button(text,varargin{:});
            param@param_generic(text,val,varargin{:});
        end
        
        function size=get_draw_size(param,panel)
            size=get_draw_size@param_generic(param,panel);
            size(1)=size(1)+param.width_element3; % how wide every element is
        end
        
        function select_callback(param)
            [nam,dir]=uigetfile('*.*','select a file');
            if ~isequal(nam,0)
                setvalue(param,fullfile(dir,nam));
            end
            set_changed_status(param.parent,1);
            param.is_changed=1;
        end
        
        function draw(param,parentpanel,x,y)
            draw@param_generic(param,parentpanel,x,y);
            draw@param_button(param,parentpanel,x,y);
            selectfct=@(src,event)select_callback(param);
            set(param.hand(3),'ButtonPushedFcn',selectfct);
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