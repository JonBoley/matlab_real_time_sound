



classdef parameter < handle
    properties (SetAccess = protected)
        %         size;
        text;
        value;
        hand=0; % handle of screen representation
        guihandle=-1;
        width_element2;
        width_element3;
        parent;
        is_changed=1;
        callback_function; % some parameters want to call someone when changed.
        callback_target=[]; % can be set to modify specific objects in other contexts
    end
    properties (SetAccess=public)
        panelnr; % the container map does not keep track of order, so I need to
        unit_scalex;
        unit_scaley;
    end
    
    methods
        function param=parameter(text,val,varargin)
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'callback_function','');
            addParameter(pars,'callback_target',[]);
            
            parse(pars,varargin{:});
            
            param.callback_target=pars.Results.callback_target;
            param.callback_function=pars.Results.callback_function;
            param.text=text;
            param.value=val;
            
            param.unit_scalex=10; % how many pixels roughly one character in width
            param.unit_scaley=30; % how many pixels roughly one character in height
            param.width_element2=10*param.unit_scalex;
            param.width_element3=10*param.unit_scalex;
            
        end
        
        function si=get_text_size(obj,panel) % find out how many pixels I am
            
            % it doesn't work to ask for size after plotting, in 2019a text
            % doesn't work in uipanel and uilabel doesn't automatically
            % size
            
            si(1)=8*length(obj.text);
            si(2)=25;
        end
        
        function set_parent(param,parent)
            param.parent=parent;
        end
        
        function v=getvalue(param)  % get the value of this param
            v=param.value;
        end
        
        function setvalue(param,v)  % set the value of this param
            param.value=v;
            if param.hand(1)>0
                set(param.hand(2),'Value',string(param.value));
            end
            param.is_changed=1;
        end
        
        function size=get_draw_size(param,panel)
            si=get_text_size(param,panel);
            size(1)=param.width_element2+si(1); % how wide every element is
            size(2)=param.unit_scaley;  % how high an edit box is
        end
        
        function callback_change_value(param)
            param.value=get(param.hand(2),'Value');
            param.is_changed=1;
            eval(param.callback_function); % and tell the rest of the world, if they are listening
        end
        
        
        function [elem1,elem2,elem3]=getelementpositions(param,parentpanel,x,y)
            % position of text element:
            stext=get_text_size(param,parentpanel);
            elem1.x=x; % left
            elem1.y=y; % top
            elem1.w=stext(1);
            elem1.h=stext(2);
            
            % position of edit element:
            elem2.x=x+elem1.w+param.unit_scalex;
            elem2.y=elem1.y;
            elem2.w=param.width_element2;
            elem2.h=elem1.h;
            
            % position of unit element:
            elem3.x=elem1.x+elem1.w+elem2.w+2*param.unit_scalex;
            elem3.y=elem1.y;
            elem3.w=param.width_element2;
            elem3.h=elem1.h;
        end
        
        % draw puts in on the screen. The base class put's on a text and
        function draw(param,parentpanel,x,y)
            elem1=getelementpositions(param,parentpanel,x,y);
            
            
            ut=uilabel(parentpanel);
            ut.BackgroundColor=[0.94 0.94 0.94];
            ut.Position=[elem1.x elem1.y elem1.w elem1.h];
            ut.Text=param.text;
            ut.FontSize=14;
            ut.HorizontalAlignment='right';
            param.hand(1) = ut;
        end
        
        
        function gui(param,mode) % put the gui on the screen (modal or not)
            param.guihandle=figure;
            set(param.guihandle,'MenuBar','none','Units','character','Resize','off');
            set(0,'Units','character')
            pos=get(param.guihandle,'Position'); % resize figure
            pos(3)=param.size(1)+3;
            pos(4)=param.size(2)+2;
            set(param.guihandle,'Position',pos);
            draw(param,param.guihandle,1,1);
        end
        
        function b=has_changed(param)
            b=param.is_changed;
        end
        
        function set_changed_status(param,v)
            param.is_changed=v;
        end
        
        function s=get_value_string(param)
            % return the pair 'name', value, as needed for disp and
            % varargin
            % if not overriding this, we assume value is a string
            v=getvalue(param);
            s = sprintf('''%s'',''%s''',param.text,v);
        end
        
        function disp(param)
            s=get_value_string(param);
            fprintf('%s\n',s);
        end
    end
end