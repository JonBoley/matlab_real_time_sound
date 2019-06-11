%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% input module that adds the content of a file to the signal.
classdef rt_add_file < rt_input
    properties
        attenuation;
        recorder;
        fileFs;
        file_frame_length;
    end
    
    methods
        function obj=rt_add_file(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});
            obj.fullname='add from file';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'filename','');
            addParameter(pars,'foldername',pwd);
            addParameter(pars,'attenuation',0);
            parse(pars,varargin{:});
            add(obj.p,param_filename('filename',pars.Results.filename));
            add(obj.p,param_foldername('foldername',pars.Results.foldername));
            add(obj.p,param_float_slider('attenuation',pars.Results.attenuation,'minvalue',-20,'maxvalue',30,'unittype',unit_mod,'unit','dB'));
            obj.input_source_type='file';

        end
        
        function post_init(obj) % called the second times around
            post_init@rt_input(obj);
            
            close(obj);
            od=cd(getvalue(obj.p,'foldername'));
            afr = dsp.AudioFileReader(getvalue(obj.p,'filename'));
            obj.fileFs=afr.SampleRate;
            
            obj.file_frame_length=calc_frame_length(obj,obj.fileFs,obj.parent.SampleRate,obj.parent.FrameLength);
            obj.recorder= dsp.AudioFileReader(getvalue(obj.p,'filename'),'PlayCount',inf,'SamplesPerFrame',obj.file_frame_length);
            cd(od);
                        
        end
        
        function nsig=read_next(obj)
            
            nsig = obj.recorder();
            nsig=resample(nsig,obj.parent.SampleRate,obj.fileFs); % ressample to wanted SR
            nsig=input_calibrate(obj,nsig);
            
            %             nsig=read_next@rtinput_file(obj); % use parent fct for reading
            atten=getvalue(obj.p,'attenuation');
%             atten=getvalue(atten);
            nsig=nsig*power(10,-atten/20);
            obj.parent.clean_stim=obj.parent.current_stim;
            if length(nsig)>length(obj.parent.current_stim) % unfortunatly can happen when having weired sampe rates
                nsig=nsig(1:length(obj.parent.current_stim)); % force them to be the same
            end
            nsig=obj.parent.current_stim+nsig; % the ADD part: add to the clean stim
        end
        
        function close(obj)
            if ~isempty(obj.recorder)
                release(obj.recorder);
            end
        end
    end
end
