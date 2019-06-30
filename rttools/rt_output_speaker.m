%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% input module, can return signals
classdef rt_output_speaker < rt_output
    properties
        my_out_equalizer
    end
    
    methods
        function obj=rt_output_speaker(parent,varargin) %% called the very first time around
            obj@rt_output(parent,varargin{:});
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'system_output_type','Default');
            addParameter(pars,'Calibrate',1);
            addParameter(pars,'CalibrationFile','AKG_K271_MkII_1_3_octave.m');
            parse(pars,varargin{:});
            obj.fullname=sprintf('speaker output: %s',pars.Results.system_output_type);
            pre_init(obj);  % add the parameter gui
            add(obj.p,param_checkbox('Calibrate',pars.Results.Calibrate));
            add(obj.p,param_generic('system_output_type',pars.Results.system_output_type));
            add(obj.p,param_filename('CalibrationFile',pars.Results.CalibrationFile));
            
            obj.output_drain_type='speaker'; % I am a speaker (or headphone)
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_output(obj);
            if ~isempty(obj.parent.player) % first release the old one
                release(obj.parent.player);
            end
            target=getvalue(obj.p,'system_output_type');
            obj.parent.player =  audioDeviceWriter('SampleRate',obj.parent.SampleRate,'Device',target);
            setup(obj.parent.player,zeros(obj.parent.FrameLength,obj.parent.Channels));
            
            cal=getvalue(obj.p,'Calibrate');
            if cal
                % load calibration file
                cf=getvalue(obj.p,'CalibrationFile');
                if ~contains(cf,'.m')
                    cf=[cf '.m'];
                end

                run(cf); % this loads a structure called 'calib'
                gains=calib.gains;
                
                nr=length(gains);
                switch nr
                    case 10
                        bw= '1 octave';
                    case 15
                        bw= '2/3 octave';
                    case 30
                        bw= '1/3 octave';
                end
                                
                obj.my_out_equalizer = graphicEQ('SampleRate',obj.parent.SampleRate,...
                    'EQOrder',2,...
                    'Structure','Cascade',...
                    'Bandwidth',bw,...
                    'Gains',gains);
            end
             set_changed_status(obj.p,0);
        end
        
        function write_next(obj,sig)
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            cal=getvalue(obj.p,'Calibrate');
            if cal
                sig=calibrate_out(obj,sig);
            end
            fac=power(10,(obj.parent.output_gain)/20);
            sig=sig.*fac;
            obj.parent.last_played_stim=sig; % save this stimuls for when measuring latency
            obj.parent.player(sig);
        end
        
        % calibration function
        function sig=calibrate_out(obj,sig)
            sig=obj.my_out_equalizer(sig);            
        end
        
        
        function close(obj)
            if ~isempty(obj.parent.player) % first release the old one
                release(obj.parent.player);
            end
        end
    end
end
