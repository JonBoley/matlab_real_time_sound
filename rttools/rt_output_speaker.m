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
            addParameter(pars,'CalibrationFile','HeadphonesAKGK271.m');
%             %             addParameter(pars,'Gains','20,10,2,3.3,-19.2,-19.7,-21.3,-13.6,-4.6,10');  % values recorded by SBleeck 20.6.2019 for AKG K271 Headphones
%             % pref frequencies (1 oct):    31.5 63 125 250 500 1000 2000 4000 8000 16000
%             % pref frequencies (2/3 oct):  25   40  63 100 160  250  400  630 1000  1600  2500  4000  6300  10000 16000
%             addParameter(pars,'Gains','    20,  17,  3,  2,  6,  -4, -19, -21, -20,  -21,  -17,  -11,   -5,     7,    9');
            parse(pars,varargin{:});
            obj.fullname=sprintf('speaker output: %s',pars.Results.system_output_type);
            pre_init(obj);  % add the parameter gui
            add(obj.p,param_checkbox('Calibrate',pars.Results.Calibrate));
            add(obj.p,param_generic('system_output_type',pars.Results.system_output_type));
%             add(obj.p,param_generic('Gains',pars.Results.Gains));
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
