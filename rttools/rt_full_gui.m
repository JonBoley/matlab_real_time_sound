%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_full_gui <handle%#Lklklk11
    properties
        
        all_manipulations=[];  % bag to store links to the maniplations in one place (it's easier)
        all_visualizations=[];
        all_measurements=[];
        
        pathes;
        mymodel;
        modules
        display_modules;
        p;
        
        
        input_process=[];
        add_noise_process=[];
        manipulation_process=[];
        visualization_process=[];
        measurement_process=[];
        output_process=[];
        
        tlast
        speedtimer
        main_figure
        
        
        viz_panel; % panel that vizualzier use
        meas_panel; % panel that measurer use
        
    end
    
    methods
        
        function obj=rt_full_gui()
            obj.pathes.toolpath  = './rttools'; % where my tools are
            obj.pathes.modulepath= './rtmodules'; % where all my modules are
            obj.pathes.noisepath = './noises'; % where the noises are
            obj.pathes.wavpath   = './randomwavs'; % where the random files are
            
            obj.mymodel=rt_model;  % start the main model with default parameter
            obj.mymodel.parent=obj;  % set myself as the parent
            obj.p=obj.mymodel.p; % drastic: copy over all main model parameter
            %             add(obj.p,param_button('press to calibrate','button_text','button...','button_callback_function','calibrate(param.parent.parent.parent);'));
            
            obj.modules=containers.Map;
            for i=1:3
                obj.display_modules{i}=containers.Map;
            end
        end
        
        function init(obj)
            %% add all sources
            add_sources(obj);
            %% find all Modules that are in the folder 'modules'
            add_all_modules(obj, obj.pathes.modulepath);
            
            %% AddNoises
            add_noises(obj, obj.pathes.noisepath);
            %% add targets
            add_targets(obj);
            add(obj.p,param_button('save script','button_callback_function','save_script_file(param.parent.parent.parent);'));
            myswitch=param_switch_with_light('IsRunning',1,'callback_function','run(param.parent.parent.parent);');
            add(obj.p,myswitch);
            add(obj.p,param_text('RealTimeSpeed','x'));
            obj.mymodel.IsRunning=1;
            obj.tlast=0;
            obj.speedtimer=timer('Period',1,'ExecutionMode','fixedRate','TimerFcn','timer_event_fct(obj);');
            %% create one big output window
            obj.main_figure=create_main_figure(obj,1200,800);
            
            setvalue(obj.p,'SoundSource','load from random file');
            setvalue(obj.p,'AddNoise',0);
            setvalue(obj.p,'Noise','pink.wav');
            setvalue(obj.p,'Visualizations','Waveform');
            setvalue(obj.p,'applyManipulation',0);
            setvalue(obj.p,'showVisualization',1);
            setvalue(obj.p,'doMeasurement',0);
            setvalue(obj.p,'Measurements','Decibel Sound Pressure Level');
            setvalue(obj.p,'SoundTarget','speaker output: Default');
            setvalue(obj.p,'PlaySound',0);
                      
            fullgui_post_init(obj,'input');
            fullgui_post_init(obj,'noise');
            fullgui_post_init(obj,'manipulation');
            fullgui_post_init(obj,'visualization');
            fullgui_post_init(obj,'measurement');
            fullgui_post_init(obj,'output');
            set_changed_status(obj.p,0); % und gut ist
        end
        
        function add_sources(obj)
            ADR = audioDeviceReader;
            devices=getAudioDevices(ADR);
            
            o=rt_input_output(obj);
            sources{1}=o.fullname;
            obj.modules(sources{1})=o;
            
            o=rt_input_file_random(obj,'foldername',obj.pathes.wavpath);
            sources{2}=o.fullname;
            obj.modules(sources{2})=o;
            
            o=rt_input_file(obj,'foldername',pwd);
            sources{3}=o.fullname;
            obj.modules(sources{3})=o;
            
            o=rt_input_oscillator(obj);
            sources{4}=o.fullname;
            obj.modules(sources{4})=o;
            
            n=length(sources);
            for i=1:length(devices)
                n=n+1;
                sources{n}=devices{i};
                o=rt_input_microphone(obj,'system_input_type',sources{n});
                sources{n}=o.fullname; % name has changed
                obj.modules(o.fullname)=o;
            end
            pp=param_popupmenu_with_button('SoundSource',sources{1},'list',sources,...
                'button_text','properties',...
                'button_callback_function','change_param(param.button_target,''input'');','button_target',obj);
            add(obj.p,pp);
        end
        
        function add_targets(obj)
            ADR = audioDeviceWriter;
            devices=getAudioDevices(ADR);
            
            o=rt_input_output(obj);
            targets{1}=o.fullname;
            obj.modules(targets{1})=o;
            
            o=rt_output_file(obj,'filename','notyet');
            targets{2}=o.fullname;
            obj.modules(targets{2})=o;
            
            n=length(targets);
            for i=1:length(devices)
                n=n+1;
                targets{n}=devices{i};
                o=rt_output_speaker(obj,'system_output_type',targets{n});
                targets{n}=o.fullname; % name has changed
                obj.modules(o.fullname)=o;
            end
            pp=param_popupmenu_with_button('SoundTarget',targets{end},'list',targets,...
                'button_text','properties',...
                'button_callback_function','change_param(param.button_target,''output'');','button_target',obj);
            
            add(obj.p,pp);
            add(obj.p,param_checkbox('PlaySound',0));
        end
        
        function add_noises(obj,adir)
            od=cd(adir); % add all noises from one directory
            d=dir;
            alln={};c=0;
            for i=1:length(d)
                if length(d(i).name)>4 && isequal(d(i).name(end-3:end),'.wav')
                    c=c+1;
                    alln{c}=d(i).name;
                end
            end
            cd(od);
            
            o=rt_add_file(obj,'foldername',obj.pathes.noisepath);
            % noise is special and must be added out of sync here. It will
            % never change (always the same base module) and we want to
            % mirror it's parameter here
            add_module(obj.mymodel,o,'input'); %
            
            add(obj.p,param_popupmenu('Noise',alln{1},'list',alln));
            add(obj.p,param_checkbox('AddNoise',0));
            
            npar=getparameter(obj.mymodel.add_noise_process.basic_module.p,'attenuation');
            add(obj.p,npar);
            
            ingain=param_slider('InputGain',0,'minvalue',-20,'maxvalue',50,'callback_function','change_gains(param.parent.parent.parent);');
            add(obj.p,ingain);
            
            outgain=param_slider('OutputGain',0,'minvalue',-20,'maxvalue',50,'callback_function','change_gains(param.parent.parent.parent);');
            add(obj.p,outgain);
        end
        
        function change_gains(obj)
            obj.mymodel.input_gain=getvalue(obj.p,'InputGain');
            obj.mymodel.output_gain=getvalue(obj.p,'OutputGain');
        end
        
        % post_init is called after all modules are registered
        function fullgui_post_init(obj,type)
            obj.mymodel.PlotWidth=getvalue(obj.p,'PlotWidth','sec');
            switch type
                case 'input'
                    sourcename=getvalue(obj.p,'SoundSource');
                    obj.mymodel.Channels=getvalue(obj.p,'Channels');
                    obj.mymodel.FrameLength=getvalue(obj.p,'FrameLength');
                    obj.mymodel.SampleRate=getvalue(obj.p,'SampleRate');
                    source=obj.modules(sourcename);
                    newprocess=add_module(obj.mymodel,source,'input');
                    replace_process(obj.mymodel,obj.input_process,newprocess); % replace the old process
                    obj.input_process=newprocess;
                    initialize(obj.input_process);
                    
                case 'noise'
                    noisewav=getvalue(obj.p,'Noise');
                    setvalue(obj.mymodel.add_noise_process.basic_module.p,'filename',noisewav);
                    post_init(obj.mymodel.add_noise_process.basic_module);
                             
                case 'manipulation'
                    maisel=getvalue(obj.p,'Manipulations');
                    obj.mymodel.OverlapAdd=getvalue(obj.p,'OverlapAdd');
                    newprocess=add_module(obj.mymodel,obj.modules(maisel),'manipulation');
                    replace_process(obj.mymodel,obj.manipulation_process,newprocess); % replace the old process
                    obj.manipulation_process=newprocess;
                    initialize(obj.manipulation_process);
                    
                case 'visualization'
                    visusel=getvalue(obj.p,'Visualizations');
                    newprocess=add_module(obj.mymodel,obj.modules(visusel),'visualization');
                    replace_process(obj.mymodel,obj.visualization_process,newprocess); % replace the old process
                    obj.visualization_process=newprocess;
                    obj.visualization_process.viz_panel=obj.viz_panel;
                    initialize(obj.visualization_process);
                    
                case 'measurement'
                    meassel=getvalue(obj.p,'Measurements');
                    newprocess=add_module(obj.mymodel,obj.modules(meassel),'measurement');
                    replace_process(obj.mymodel,obj.measurement_process,newprocess); % replace the old process
                    obj.measurement_process=newprocess;
                    obj.measurement_process.meas_panel=obj.meas_panel;
                    initialize(obj.measurement_process);
                    
                case 'output'
                    targetname=getvalue(obj.p,'SoundTarget');
                    target=obj.modules(targetname);
                    newprocess=add_module(obj.mymodel,target,'output');
                    replace_process(obj.mymodel,obj.output_process,newprocess); % replace the old process
                    obj.output_process=newprocess;
                    initialize(obj.output_process);
            end
        end
        
        function change_param(obj,targ)
            switch targ
                case 'input'
                    v=obj.modules(getvalue(obj.p,'SoundSource'));
                    change_parameter(v);
                case 'output'
                    v=obj.modules(getvalue(obj.p,'SoundTarget'));
                    change_parameter(v);
                case 'vizualization'
                    v=obj.modules(getvalue(obj.p,'Visualizations'));
                    change_parameter(v);
                case 'manipulation'
                    v=obj.modules(getvalue(obj.p,'Manipulations'));
                    change_parameter(v);
                case 'measurement'
                    v=obj.modules(getvalue(obj.p,'Measurements'));
                    change_parameter(v);
            end
        end
        
        function add_all_modules(obj,wdir)
            od=cd(wdir);
            l=dir();
            for i=1:length(l)
                if ~isempty(strfind(l(i).name,'.m')) ...
                        && isempty(strfind(l(i).name,'~')) ...
                        
                    name=l(i).name(1:end-2);
                    str=sprintf('o=%s(obj);',name);
                    eval(str);
                    obj.modules(o.fullname)=o;
                    
                    if o.is_manipulation %% add to screen as manipulation
                        obj.display_modules{1}(o.fullname)=o;
                    end
                    
                    if o.is_visualization %% add to screen:
                        obj.display_modules{2}(o.fullname)=o;
                    end
                    
                    if o.is_measurement
                        obj.display_modules{3}(o.fullname)=o;
                    end
                end
            end
            cd(od);
            
            k=keys(obj.display_modules{1});
            add(obj.p,param_popupmenu_with_button('Manipulations',k{1},'list',k,...
                'button_text','properties',...
                'button_callback_function','change_param(param.parent.parent.parent,''manipulation'');'));
            add(obj.p,param_checkbox('applyManipulation',0));
            
            k=keys(obj.display_modules{2});
            add(obj.p,param_popupmenu_with_button('Visualizations',k{1},'list',k,...
                'button_text','properties',...
                'button_callback_function','change_param(param.parent.parent.parent,''vizualization'');'));
            add(obj.p,param_checkbox('showVisualization',0));
            
            k=keys(obj.display_modules{3});
            add(obj.p,param_popupmenu_with_button('Measurements',k{1},'list',k,...
                'button_text','properties',...
                'button_callback_function','change_param(param.parent.parent.parent,''measurement'');'));
            add(obj.p,param_checkbox('doMeasurement',0));
            
        end
        
        function updateparams(obj)
            %% check what has changed and decide if it's important to rerun initialization
            if has_changed(getparameter(obj.p,'SoundSource'))
                fullgui_post_init(obj,'input');
            end
            
            if  has_changed(getparameter(obj.p,'OverlapAdd'))
                fullgui_post_init(obj,'manipulation');
            end
            
            if has_changed(getparameter(obj.p,'SampleRate')) || ...
                    has_changed(getparameter(obj.p,'FrameLength'))  % change them all!
                fullgui_post_init(obj,'input');
                fullgui_post_init(obj,'noise');
                fullgui_post_init(obj,'manipulation');
                fullgui_post_init(obj,'visualization');
                fullgui_post_init(obj,'measurement');
                fullgui_post_init(obj,'output');
            end
            
            
            if has_changed(getparameter(obj.p,'Channels'))
                fullgui_post_init(obj,'input');
                fullgui_post_init(obj,'noise');
                fullgui_post_init(obj,'manipulation');
                fullgui_post_init(obj,'visualization');
                fullgui_post_init(obj,'output');
            end
            
            if has_changed(getparameter(obj.p,'PlotWidth'))
                % some error checking. must be longer than the framelength
                w=getvalue(obj.p,'PlotWidth');
                n=getvalue(obj.p,'FrameLength');
                sr=getvalue(obj.p,'SampleRate');
                if n>ceil(w*sr)
                    disp('plotwitdh must be longer than framelength!');
                    setvalue(obj.p,'PlotWidth',n/sr);
                end
                fullgui_post_init(obj,'visualization');
                fullgui_post_init(obj,'measurement');
            end
            
            if has_changed(getparameter(obj.p,'SoundTarget'))
                fullgui_post_init(obj,'output');
            end
            
            if has_changed(getparameter(obj.p,'Manipulations'))
                fullgui_post_init(obj,'manipulation');
            end
            
            if has_changed(getparameter(obj.p,'Visualizations'))
                fullgui_post_init(obj,'visualization');
            end
            
            if has_changed(getparameter(obj.p,'Measurements'))
                fullgui_post_init(obj,'measurement');
            end
            
            if has_changed(getparameter(obj.p,'Noise'))
                fullgui_post_init(obj,'noise');
            end
            
            
        end
        
        % shows the whole GUI and initializes is
        function main_figure=create_main_figure(obj,sx,sy)
            if nargin<3
                sx=100;
                sy=100;
            end
            % open a window
            main_figure=uifigure;
            
            set(0,'units','pixel');
            screensize=get(0,'ScreenSize');
            pos=get(main_figure,'Position'); % resize figure
            main_figure.Scrollable='off';
            if sx>screensize(3)
                main_figure.Scrollable='on';
                sx=screensize(3);
            end
            if sy>screensize(4)
                main_figure.Scrollable='on';
                sy=screensize(4);
            end
            % put the window in the centre
            pos(1)=screensize(3)/2-sx/2;
            pos(2)=screensize(4)/2-sy/2;
            set(main_figure,'Position',pos);
            
            main_figure.MenuBar='none';
            main_figure.Resize='on';
            main_figure.Name='Sound!';
            main_figure.CloseRequestFcn='myclose(obj);';
            
            main_figure.Position(3)=sx;
            main_figure.Position(4)=sy;
            obj.main_figure=main_figure;
            
            % right side: controls
            [maxtotalwidth,totalheight,~]=get_size(obj.p,main_figure);
            
            %% visual parameter
            %             buttonheight=30;
            edge=1;  % how much around each side
            paneltitlehight=40; % each panel comes with a title this height
            
            maxtotalwidth=maxtotalwidth+50; % fiddling, not sure why
            totalheight=totalheight+paneltitlehight; % for the title line
            
            %% put the GUI on the screen
            hbsp = uipanel(main_figure,'Position',[sx-maxtotalwidth-edge 10 maxtotalwidth totalheight]);
            hbsp.BackgroundColor=[0.9 0.9 0.8];
            hbsp.Scrollable='on';
            hbsp.Title='Controls';
            gui(obj.p,'non-modal',hbsp);  % start the gUI
            
            %% create a visualization panel
            pansize=[700 490];
            obj.viz_panel = uipanel(main_figure,'Position',[edge sy-pansize(2)-edge-paneltitlehight pansize(1) pansize(2)]);
            obj.viz_panel.BackgroundColor=[1 0 0];
            obj.viz_panel.Scrollable='on';
            obj.viz_panel.Title='Vizualization';
            
            %% create a measurement panel. Objects can fill it
            pansize2=[700 250];
            obj.meas_panel = uipanel(main_figure,'Position',[edge edge pansize2(1) pansize2(2)]);
            obj.meas_panel.BackgroundColor=[ 0 1 0];
            obj.meas_panel.Scrollable='on';
            obj.meas_panel.Title='Measurements';
        end
        
        function timer_event_fct(obj)
            t=obj.mymodel.global_time;
            s=sprintf('%2.2f * RT',t-obj.tlast);
            setvalue(obj.p,'RealTimeSpeed',s);
            obj.tlast=t;
        end
        
              
        function run(obj)
            if getvalue(obj.p,'IsRunning')==0
                obj.mymodel.IsRunning=0;
            else
                if ~isequal(obj.speedtimer.Running,'on')
                    start(obj.speedtimer);
                end
                obj.mymodel.IsRunning=1;
                obj.mymodel.frame_counter=0;
                obj.mymodel.global_time=0;
                while obj.mymodel.IsRunning
                    obj.mymodel.frame_counter=obj.mymodel.frame_counter+1; % and reset global counters
                    
                    % check if parameters have changed
                    if has_changed(obj.p)
                        updateparams(obj);
                        set_changed_status(obj.p,0);
                    end
                    % run all parts - in the full gui, there can only ever be 6!
                    
                    % input is always there:
                    process(obj.input_process);
                    
                    if getvalue(obj.p,'AddNoise')
                        process(obj.mymodel.add_noise_process);
                    end
                    
                    if getvalue(obj.p,'applyManipulation')
                        process(obj.manipulation_process);
                    end
                    
                    if getvalue(obj.p,'showVisualization')
                        process(obj.visualization_process);
                    end
                    
                    if getvalue(obj.p,'doMeasurement')
                        process(obj.measurement_process);
                    end
                    if getvalue(obj.p,'PlaySound')
                        process(obj.output_process);
                    end
                    obj.mymodel.global_time=obj.mymodel.global_time+obj.mymodel.FrameLength/obj.mymodel.SampleRate;
                    drawnow limitrate
                    
                    obj.mymodel.global_time=obj.mymodel.global_time+obj.mymodel.FrameLength/obj.mymodel.SampleRate;
                    if obj.mymodel.global_time>getvalue(obj.mymodel.p,'Duration')
                        obj.mymodel.IsRunning=0;
                        setvalue(obj.p,'IsRunning',0);
                        break
                    end
                end
                
                if isequal(obj.speedtimer.Running,'on')
                    stop(obj.speedtimer);
                end
                obj.mymodel.IsRunning=0;
            end
        end
        
        function myclose(obj)
            stop(obj.speedtimer);
            close(obj.mymodel);
            delete(obj.main_figure);
            obj.main_figure=-1;
        end
        
        function save_script_file(obj,fname)
            % save a minimum script that can run standalone (and easily expanded)
            od=cd(fullfile(obj.mymodel.rootfolder,'scripts'));
            if nargin<2
                fname='script_last_saved';
                fname=get_new_filename(fname,'m');
            end
            s=[];n=0;
            
            %add the right path
            n=n+1;s{n}='clear all';
            n=n+1;s{n}='clc';
            n=n+1;s{n}='close all force';
            n=n+1;s{n}='addpath(genpath(''../rttools''));';
            n=n+1;s{n}='addpath(genpath(''../rtmodules''));';
            n=n+1;s{n}='addpath(genpath(''../thirdparty''));';
            
            % create the model,(with graphics)
            pstr=get_param_value_string(obj.p);
            valstr=[];
            for i=1:6  % only take the main parameter, not the fluid ones below
                valstr=[valstr pstr{i}];
                if i<6
                    valstr=[valstr ','];
                end
            end
            n=n+1;s{n}=sprintf('mymodel=rt_model(%s);',valstr);
            
            modnr=1;
            % input is always there:
            mod=obj.input_process.basic_module;
            modstr=get_as_script_string(mod);
            n=n+1;s{n}=sprintf('module_%d=%s;',modnr,modstr);
            n=n+1;s{n}=sprintf('add_module(mymodel,module_%d);',modnr);
            modnr=modnr+1;
            
            if getvalue(obj.p,'AddNoise')
                mod=obj.add_noise_process.basic_module;
                modstr=get_as_script_string(mod);
                n=n+1;s{n}=sprintf('module_%d=%s;',modnr,modstr);
                n=n+1;s{n}=sprintf('add_module(mymodel,module_%d);',modnr);
                modnr=modnr+1;
            end
            
            if getvalue(obj.p,'applyManipulation')
                mod=obj.manipulation_process.basic_module;
                modstr=get_as_script_string(mod);
                n=n+1;s{n}=sprintf('module_%d=%s;',modnr,modstr);
                n=n+1;s{n}=sprintf('add_module(mymodel,module_%d);',modnr);
                modnr=modnr+1;
            end
            
            if getvalue(obj.p,'showVisualization')
                mod=obj.visualization_process.basic_module;
                modstr=get_as_script_string(mod);
                n=n+1;s{n}=sprintf('module_%d=%s;',modnr,modstr);
                n=n+1;s{n}=sprintf('add_module(mymodel,module_%d);',modnr);
                modnr=modnr+1;
            end
            
            if getvalue(obj.p,'doMeasurement')
                mod=obj.measurement_process.basic_module;
                modstr=get_as_script_string(mod);
                n=n+1;s{n}=sprintf('module_%d=%s;',modnr,modstr);
                n=n+1;s{n}=sprintf('add_module(mymodel,module_%d);',modnr);
                modnr=modnr+1;
            end
            if getvalue(obj.p,'PlaySound')
                mod=obj.output_process.basic_module;
                modstr=get_as_script_string(mod);
                n=n+1;s{n}=sprintf('module_%d=%s;',modnr,modstr);
                n=n+1;s{n}=sprintf('add_module(mymodel,module_%d);',modnr);
            end
            
            % then initialize and run
            n=n+1;s{n}='gui(mymodel);';
            n=n+1;s{n}='initialize(mymodel);';
            n=n+1;s{n}='run_once(mymodel);';
            n=n+1;s{n}='close(mymodel);';
            
            savetofile(s,fname);
            cd(od);
            
        end
    end
end
