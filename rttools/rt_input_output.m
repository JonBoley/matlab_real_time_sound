%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% input module, can return signals
classdef rt_input_output < rt_output & rt_input
    properties
        playerrecorder;
        previous_in
        next_out
        my_out_equalizer
        my_in_equalizer
        my_calib
        my_direction
    end
    
    methods
        function obj=rt_input_output(parent,varargin) %% called the very first time around
            obj@rt_output(parent,varargin{:});
            obj@rt_input(parent,varargin{:});
            
            obj.fullname='audio synchronous in/output';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            choices={'first record then play';'first play then record'};
            addParameter(pars,'Direction',choices{1});
            addParameter(pars,'Calibrate',0);
            addParameter(pars,'InGains','0,0,0,0,0,0,0,0,0,0');
            addParameter(pars,'OutGains','0,0,0,0,0,0,0,0,0,0');
            
            parse(pars,varargin{:});
            add(obj.p,param_checkbox('Calibrate',pars.Results.Calibrate));
            add(obj.p,param_popupmenu('Direction',pars.Results.Direction,'list',choices));
            add(obj.p,param_generic('InGains',pars.Results.InGains));
            add(obj.p,param_generic('OutGains',pars.Results.OutGains));
            
            
            obj.output_drain_type='mic_speaker'; % I am both mic and speaker
            obj.input_source_type='mic_speaker'; % I am both mic and speaker
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_output(obj);
            post_init@rt_input(obj);
            if ~isempty(obj.playerrecorder) % first release the old one
                release(obj.playerrecorder);
            end
            % set my parent to the same input AND output
            %             try % only if this is called from the gui
            gp=obj.parent.parent;
            if ~isempty(gp)
                setvalue(gp.p,'SoundSource',obj.fullname); % set the input and output to mylsef
                setvalue(gp.p,'SoundTarget',obj.fullname); % set the input and output to mylsef
            end
            
            obj.playerrecorder =  audioPlayerRecorder('SampleRate',obj.parent.SampleRate);
            
            obj.previous_in=zeros(obj.parent.FrameLength,1);
            obj.next_out=zeros(obj.parent.FrameLength,1);
            
            cal=getvalue(obj.p,'Calibrate');
            if cal
                ingains=parse_csv(getvalue(obj.p,'InGains'));
                outgains=parse_csv(getvalue(obj.p,'OutGains'));
                
                obj.my_out_equalizer = graphicEQ('SampleRate',obj.parent.SampleRate,...
                    'EQOrder',2,...
                    'Structure','Cascade',...
                    'Bandwidth','1 octave',...
                    'Gains',outgains);
                obj.my_in_equalizer = graphicEQ('SampleRate',obj.parent.SampleRate,...
                    'EQOrder',2,...
                    'Structure','Cascade',...
                    'Bandwidth','1 octave',...
                    'Gains',ingains);
            end
            
            obj.my_calib=getvalue(obj.p,'Calibrate');
            direction=getvalue(obj.p,'Direction');
            if isequal(direction,'first record then play')
                obj.my_direction=1;
            else
                obj.my_direction=0;
            end
            
        end
        
        function sig=read_next(obj)  % rather than using the microphone, we just return the previously saved input buffer
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            
            if obj.my_direction          % standard way, first record, then play
                sig=obj.previous_in(:);
            else
                sig = obj.playerrecorder(obj.next_out);
            end
            obj.parent.last_recorded_stim=sig;
            
            if obj.my_calib
                sig=calibrate_in(obj,sig);
            end
            fac=power(10,(obj.parent.input_gain)/20);
            sig=sig.*fac;
        end
        
        function write_next(obj,sig)  % in the writing cycle, we also get the next input buffer for free
            if obj.my_calib
                sig=calibrate(obj,sig);
            end
            fac=power(10,(obj.parent.output_gain)/20);
            sig=sig.*fac;
            
            obj.parent.last_played_stim=sig; % save this stimuls for when measuring latency
            if obj.my_direction          % standard way, first record, then play
                sig_rec = obj.playerrecorder(sig);
                obj.previous_in=sig_rec; % just save it, ready for play!
            else  % could be otherwise, eg for measurement of latency
                obj.next_out=sig;
            end
            
        end
        
        % calibration function
        function sig=calibrate_out(obj,sig)
            sig=obj.my_out_equalizer(sig);
        end
        
        % calibration function
        function sig=calibrate_in(obj,sig)
            sig=obj.my_in_equalizer(sig);
        end
        
        
        function close(obj)
            if ~isempty(obj.playerrecorder) % first release the old one
                release(obj.playerrecorder);
            end
        end
    end
end
