%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_input_microphone < rt_input
    properties
        recorder;
        my_in_equalizer
    end
    
    methods
        function obj=rt_input_microphone(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'Calibrate',0);
            addParameter(pars,'Gains','0,0,0,0,0,0,0,0,0,0');
            addParameter(pars,'system_input_type','Default');
            parse(pars,varargin{:});
            obj.fullname=sprintf('microphone input: %s',pars.Results.system_input_type);
            
            pre_init(obj);  % add the parameter gui
            add(obj.p,param_checkbox('Calibrate',pars.Results.Calibrate));
            add(obj.p,param_generic('system_output_type',pars.Results.system_input_type));
            add(obj.p,param_generic('Gains',pars.Results.Gains));
            
            obj.input_source_type='mic'; % I am a microphone
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_module(obj);
            
            close(obj);
            
            afr = audioDeviceReader;
            afr.SamplesPerFrame=obj.parent.FrameLength;
            afr.SampleRate=obj.parent.SampleRate;
            afr.NumChannels=obj.parent.Channels;
            afr.Device=getvalue(obj.p,'system_output_type');
            
            obj.parent.recorder=afr;
            
            cal=getvalue(obj.p,'Calibrate');
            if cal
                gains=parse_csv(getvalue(obj.p,'Gains'));
                
                obj.my_in_equalizer = graphicEQ('SampleRate',obj.parent.SampleRate,...
                    'EQOrder',2,...
                    'Structure','Cascade',...
                    'Bandwidth','1 octave',...
                    'Gains',gains);
            end
        end
        
        function sig=read_next(obj)
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            sig = obj.parent.recorder();
            
            cal=getvalue(obj.p,'Calibrate');
            if cal
                sig=calibrate_in(obj,sig);
            end
            fac=power(10,(obj.parent.input_gain)/20);
            sig=sig.*fac;
        end
        
                % calibration function
        function sig=calibrate_in(obj,sig)
            sig=obj.my_in_equalizer(sig);            
        end
        
        function close(obj)
            if ~isempty(obj.parent.recorder)
                release(obj.parent.recorder);
            end
            if ~isempty(obj.my_in_equalizer)                
                release(obj.my_in_equalizer);
            end
        end
    end
end
