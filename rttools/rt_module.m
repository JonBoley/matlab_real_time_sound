
classdef rt_module < handle & matlab.mixin.Copyable
    properties
        MAXVOLUME=100;   % not sure where to put this otherwise. The MAximum output level
        P0=2*1E-5;    % reference pressure
        
        parent;  % the object that deals with the data in and out
        fullname;
        p;   % shortcut for the parameterstructure
        
        is_measurement=0;
        is_manipulation=0;
        is_visualization=0;
        is_input=0;
        is_output=0;
        guihandle; % if we have a gui, then this is the handle
        
        show=1; % make this module visible on screen to select
        label='';
        partner=[]; % some modules depend on each other. that can be labelled here (channlels or overlap and add)
        descriptor='no description yet';
        
        channel_nr; % each module can only have one channel
    end
    
    methods
        function obj=rt_module(parent,varargin) %% called the very first time around
            obj.parent=parent;
            obj.fullname='no name given yet to this module - error!';
        end
        
        function pre_init(obj)
            obj.p=parameterbag(obj.fullname);
            add(obj.p,param_button('finished?','button_text','done  ','button_callback_function','close_gui(param.parent)'));
            add(obj.p,param_button('for more info:','button_text','show description','button_callback_function','show_description(param.button_target)','button_target',obj));
        end
        
        %optional, bt will be callsed
        function post_init(obj) % called the second times around
        end
        
        
        function close(obj)
            if ishandle(obj.guihandle)
                close(obj.guihandle);
            end
        end
        
        function show_description(obj)
%             f =  obj.parent.parent.main_figure;
            f=uifigure;
            p=f.Position;
            e=uitextarea(f,'Position',[1 1 p(3) p(4)],'Editable','off','FontSize',16);
            e.Value=obj.descriptor;
%             uialert(f,obj.descriptor,obj.fullname,'Icon','info','Modal',false);
            register_window(obj.parent,f);

%   Copyright 2019 Stefan Bleeck, University of Southampton
        end
        
        
        function change_parameter(obj)
            obj.guihandle=gui(obj.p);
            register_window(obj.parent,obj.guihandle);
        end
        
        function  ss=get_as_script_string(obj)
            % returns the obj in a form that it can be initialized in a
            % script. including all parameters in the right form
            mc=metaclass(obj);
            modname=mc.Name;
            pstr=get_param_value_string(obj.p);
            valstr=[];
            for i=1:length(pstr)
                valstr=[valstr pstr{i}];
                if i<length(pstr)
                    valstr=[valstr ','];
                end
            end
            
            ss=sprintf('%s(mymodel,%s)',modname,valstr);
        end
        
        
    end
end

