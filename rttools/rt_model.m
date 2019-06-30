%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef rt_model < handle   % derived from handle, so that every instance is just a pointer, not the full modelect
    properties
        % these properties are all variables that CAN NOT be changed during
        % running. A change in any of them will require a reinitializaiton
        SampleRate=22050;  % main sample rate
        FrameLength=256;  % nr points per frame
        Channels=1;  % one input, one output channel
        PlotWidth=1;  % in seconds: how much do we want to plot? % this is important, even if not plotting for buffer calculateions
        OverlapAdd=0; % if we want overlap and add (slow)
        
        %                 properties that are necessary for the running
        IsRunning=1;      % are we running or not
        global_time=0;    % keeps track of the overall passed time, important for plotting
        
        current_stim;  % the model can only have one currently active stimulus.
        last_played_stim; % I need this purely for the measurement of latency: store the stimulus that is last played
        last_recorded_stim; % I need this purely for the measurement of latency: store the stimulus that is last played
                clean_stim;   % when cleaning ideally, sometimes we need the clean signal stored from before adding noise

        processes=[]; % all the information about processes
        player; % each model can only have one open SoundSource and drain. Therefore make sure it's central!
        recorder;
        
%         % calibration properties
%         calibration_gain_mic=-12;  % these values are on my personal machine, might be different on different computers
%         gain_correct_speaker=3;
        input_gain=0;
        output_gain=0;
%         max_file_level=80; % we assume that a wav file of max rms has this dB SPL
        
        % properties that are neccesary for script processing (not live)
        % htis is where hte results are stored:
        measurement_result;
        frame_counter; % global counter for how many frames have run, so that we can store results for later reading
        p;              % parameter structure GUI for user interaction
        
        main_figure;  % full window
        all_windows=[];
        
        % needed for when adding noise
        snr=0;
        add_noise_process=[];  % the module that adds noise. Also used as switch for initializatio when noise is required.
        
        %         pathes; % saves some pathnames from files and modules
        myname;
        parent;
    end
    
    methods
        function model=rt_model(varargin)
            model.parent=[]; % must be set later!
            model.myname='real time sound model'; % this is me, now going to fill it
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'SampleRate',22050);
            addParameter(pars,'FrameLength',256);
            addParameter(pars,'Channels',1);
            addParameter(pars,'OverlapAdd',0);
            addParameter(pars,'Duration',inf);
            addParameter(pars,'PlotWidth',1);
            
            parse(pars,varargin{:});
            
            model.p=parameterbag('real time sound',model);
            add(model.p,param_int('SampleRate',pars.Results.SampleRate));
            add(model.p,param_int('FrameLength',pars.Results.FrameLength));
            add(model.p,param_int('Channels',pars.Results.Channels));
            add(model.p,param_float('Duration',pars.Results.Duration));
            add(model.p,param_checkbox('OverlapAdd',pars.Results.OverlapAdd));
            add(model.p,param_float('PlotWidth',pars.Results.PlotWidth,'unittype',unit_time,'unit','sec'));
            
            % everything below here are the non-critical params, that can
            % be changed during run-time (and are if you are using
            % rt_full_gui
            
            model.SampleRate=getvalue(model.p,'SampleRate');
            model.FrameLength=getvalue(model.p,'FrameLength');
            model.Channels=getvalue(model.p,'Channels');
            model.OverlapAdd=getvalue(model.p,'OverlapAdd');
            model.PlotWidth=getvalue(model.p,'PlotWidth');
        end
        
        function model=initialize(model) %setvalue up everything and initialzise
            for i=1:length(model.processes)
                initialize(model.processes{i});
                % add a button to change parameter for each module
                %                 buttex=sprintf('%s',model.processes{i}.basic_module.fullname);
                %                 butcalfct=sprintf('%s',model.processes{i}.basic_module.full_name);
                %                 model.p=add(param_button,'change params for','button_text',buttex,'button_callback_function',butcalfct);
            end
        end
        
        % find the process that contains this module:
        function  ret=getprocess(model,mod)
            ret=[];
            for i=1:length(model.processes)
                if isequal(model.processes{i}.basic_module,mod)
                    ret=model.processes{i};
                    return
                end
            end
        end
        
        function replace_process(model,old,new) % replace the old process with the new process, where the 'new' process is already in the cascade
            
            if isempty(old)  % the very first time, do nothing, htere wasn't an old one
                return
            end
            % first, replace the old one
            for i=1:length(model.processes)
                a=model.processes{i};
                if isequal(a,old)
                    close(model.processes{i});
                    model.processes{i}=new;
                    break;
                end
            end
            % and delete the new one from the list too:
            nr=length(model.processes);
            if isequal(model.processes{nr},new) % sanity check
                for i=1:nr-1
                    newprocesses{i}=model.processes{i};
                end
                model.processes=newprocesses;
            end
        end
        
        function opr=add_module(model,module,type)
            
            if nargin<3 % we don't know the type, assume ALL are executed (like vizualisation and manipulation)
                if module.is_input
                    add_module(model,module,'input'); % recursively: add this now defined module
                end
                if module.is_output
                    add_module(model,module,'output'); % recursively: add this now defined module
                end
                if module.is_manipulation
                    add_module(model,module,'manipulation'); % recursively: add this now defined module
                end
                if module.is_visualization
                    add_module(model,module,'visualization'); % recursively: add this now defined module
                end
                if module.is_measurement
                    add_module(model,module,'measurement'); % recursively: add this now defined module
                end
                return; % we are done!
            end
            
            % now we know the type and it can only be one!
            switch type
                case 'input'
                    opr=rtprocess_input(model,module); %
                case 'output'
                    opr=rtprocess_output(model,module); %
                case 'manipulation'
                    opr=rtprocess_manipulation(model,module); %
                case 'visualization'
                    opr=rtprocess_visualization(model,module); %
                case 'measurement'
                    opr=rtprocess_measurement(model,module); %
            end
            
            % and add to the cascade
            nr=length(model.processes);
            model.processes{nr+1}=opr;
            
            
            % check manually if this is the add-noise module, because if it
            % is, we neeed to register:
            
            if module.is_add_noise
                model.add_noise_process=opr;
            end
        end
        
        function setPlotWidth(model,t)
            setvalue(model.p,'PlotWidth',t);
            model.PlotWidth=t;
        end
        
        function run(model,duration)
            if nargin<2
                duration= inf;
            end
            
            reset(model)            
            model.IsRunning=1;
            while model.IsRunning
                model.frame_counter=model.frame_counter+1; % and reset global counters
                
                % the model can't be changed during runtime. For that,
                % use the full_gui
                % run all parts
                for i=1:length(model.processes)
                    process(model.processes{i});
                end
                model.global_time=model.global_time+model.FrameLength/model.SampleRate;
                if model.global_time>duration
                    model.IsRunning=0;
                    break
                end
                drawnow limitrate
            end
            model.IsRunning=0;
        end
        
        function run_once(model)
            duration=getvalue(model.p,'Duration');
            run(model,duration);
        end
        
        function reset(model)
            model.frame_counter=0;
            model.global_time=0;
            model.measurement_result=[];
        end
        
        function model=run_sigle_frame(model,duration)
            % specific way to run the model for very slow modules: run with a
            % frame size equal to the length of the stimulus, so we only get
            % one measurment
            model.FrameLength=model.SampleRate*duration;
            for i=1:length(model.processes)
                process(model.processes{i});
            end
        end
        
        function close(model)
            model.IsRunning=0;
            for i=1:length(model.processes)
                close(model.processes{i});
            end
            model.processes=[];
            
            nr=length(model.all_windows);
            for i=1:nr
                if ishandle(model.all_windows(i))
                    close(model.all_windows(i));
                end
            end
        end
%         
%         function set_calibrations(model,value,ingain,outgain)
%             model.calibration_gain_mic=value;
%             model.input_gain=ingain;
%             model.output_gain=outgain;
%         end
        
%         function [gain,calib]=get_input_calib(model,module)
%             % % %             % calibrate to the right level: all signal amplitudes are
%             % % %             % reported in Pascal
%             switch module.input_source_type
%                 case {'file'}
%                     maxdb=module.MAXVOLUME;
%                     maxamp=module.P0*power(10,maxdb/20);
%                     calib=20*log10(maxamp/1); % how many more dB because of pascale
%                 case {'oscillator'}
%                     maxdb=module.MAXVOLUME-3;
%                     maxamp=module.P0*power(10,maxdb/20);
%                     calib=20*log10(maxamp/1); % how many more dB because of pascale
%                 case {'mic','mic_speaker'}
%                     calib=model.calibration_gain_mic;
%             end
%             gain=model.input_gain; % simple dB added
%         end
        
%         function [gain,calib]=get_output_calib(model,module)
%             % calibrate to the right level: all signal amplitudes are reported in Pascal
%             switch module.output_drain_type
%                 case {'speaker','mic_speaker'}
%                     calib=model.calibration_gain_mic;
%             end
%             gain=model.output_gain; % simple dB added
%         end
        
        % put up a gui for this specific model and add all the requied viz panels
        function myfigurehand=gui(model,parent)
            % count the processes that need graphics representation
            %             % check how the parameters sit on the right:
            %             [guiw,guih]=get_size(model.p,f);
            
            nr_pans=0;
            for i=1:length(model.processes)
                pp=model.processes{i};
                if pp.is_visualization
                    nr_pans=nr_pans+1;
                elseif pp.is_measurement
                    nr_pans=nr_pans+1;
                end
            end
            
            if nr_pans==0  % if there are no panels, no need for a window
                myfigurehand=0;
                return
            end
            
            if nargin<2
                myfigurehand=uifigure;
                register_window(model,myfigurehand);
            else
                myfigurehand=parent;
            end
            
            
            
            % now i know there are so many panels, arrange them nicely
            if nr_pans<=4 % put them all on top of each other
                pan_height=200;
                title_height=1;
                pan_width=500;
                
                win_height=0;
                win_width=pan_width;
                for i=1:nr_pans
                    x(nr_pans-i+1)=1;
                    y(nr_pans-i+1)=1+(i-1)*(pan_height+title_height);
                    h(nr_pans-i+1)=pan_height;
                    w(nr_pans-i+1)=pan_width;
                    
                    win_height=win_height+h(nr_pans-i+1);
                end
            else % too many to make it regular, so make it square
                %                 TODO!!!!!
            end
            
            % now create all the panels and assign them to the processes:
            nr_pans=0;
            for i=1:length(model.processes)
                pp=model.processes{i};
                if pp.is_visualization
                    nr_pans=nr_pans+1;
                    pp.viz_panel=uipanel(myfigurehand,'position',[x(nr_pans) y(nr_pans) w(nr_pans) h(nr_pans)]);
                elseif pp.is_measurement
                    nr_pans=nr_pans+1;
                    pp.meas_panel=uipanel(myfigurehand,'position',[x(nr_pans) y(nr_pans) w(nr_pans) h(nr_pans)]);
                end
            end
            
            %             % now add the parametergui on the right.
            %             hbsp = uipanel(f,'Position',[win_width 1 guiw guih]);
            %             hbsp.BackgroundColor=[0.9 0.9 0.8];
            %             gui(model.p,'non-modal',hbsp);  % start the gUI
            %
            %             win_width=win_width+guiw;
            %             win_height=max(win_height,guih);
            
            
            
            % and finally set the size of the main window to capture all:
            set(0,'units','pixel');
            screensize=get(0,'ScreenSize');
            pos=get(myfigurehand,'Position'); % resize figure
            pos(3)=win_width;
            if win_height<screensize(4)
                pos(4)=win_height;
                myfigurehand.Scrollable='off';
            else
                pos(4)=screensize(4);
                myfigurehand.Scrollable='on';
            end
            pos(1)=screensize(3)-pos(3);
            pos(2)=screensize(4);
            set(myfigurehand,'Position',pos)
            model.main_figure=myfigurehand;
        end
         
        function register_window(model,f)
            nr=length(model.all_windows);
            model.all_windows(nr+1)=f;
        end
        
    end
end
