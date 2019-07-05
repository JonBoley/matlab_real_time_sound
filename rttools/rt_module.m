%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

classdef rt_module < handle & matlab.mixin.Copyable
    properties
        MAXVOLUME=100;   % not sure where to put this otherwise. The MAximum output level
        P0=2*1E-5;    % reference pressure
        
        parent;  % the object that deals with the data in and out
        fullname;
        modname;
        p;   % shortcut for the parameterstructure
        
        is_measurement=0;
        is_manipulation=0;
        is_visualization=0;
        is_input=0;
        is_output=0;
        guihandle; % if we have a gui, then this is the handle
        
        %         show=1; % make this module visible on screen to select
        label='';  % like left channel, right channel
        partner=[]; % some modules depend on each other. that can be labelled here (channlels or overlap and add)
        descriptor='no description yet';
        
        channel_nr; % each module can only have one channel
        is_add_noise=0;
        requires_noise=0;  % this module requires a clean signal and a noise signal (haspi, ibm, etc)
        requires_nr_channels=1; % the number of channels required minimum. usually one
        requires_overlap_add=0; % this module requires overlap and add switched on to work properly
        requires_frame_length =32; % standard value, must be longer in some modules
        requires_version='R2012a'; % minimum matlab verison required
        requires_toolbox=''; % which toolbox we need
    end
    
    methods
        function obj=rt_module(parent,varargin) %% called the very first time around
            obj.parent=parent;
            obj.fullname='no name given yet to this module - error!';
            obmeta=metaclass(obj);
            obj.modname=obmeta.Name;
        end
        
        function pre_init(obj)
            obj.p=parameterbag(obj.fullname);
            add(obj.p,param_button('finished?','button_text','done  ','button_callback_function','close_gui(param.parent)'));
            add(obj.p,param_button('for more info:','button_text','show description','button_callback_function','show_description(param.button_target)','button_target',obj));
        end
        
        %optional, bt will be callsed
        function post_init(obj) % called the second times around
            
            if obj.requires_frame_length>obj.parent.FrameLength
                fprintf('module %s requires a minumum frame length of %d!\n',obj.fullname,obj.requires_frame_length);
            end
            
            if obj.requires_nr_channels>obj.parent.Channels
                fprintf('module %s requires %d channels!\n',obj.fullname,obj.requires_nr_channels);
            end
            
            if obj.requires_noise && isempty(obj.parent.add_noise_process)
                fprintf('module %s requires that noise is added!\n',obj.fullname);
            end
            
            if obj.requires_overlap_add>obj.parent.OverlapAdd
                fprintf('module %s requires that overlap and add is switched on!\n',obj.fullname);
            end
            
            
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
            
            if isempty(valstr)
                ss=sprintf('%s(mymodel)',modname);
            else
                ss=sprintf('%s(mymodel,%s)',modname,valstr);
            end
        end
        
        
    end
end

