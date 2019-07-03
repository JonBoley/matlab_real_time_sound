%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_input_file < rt_input
    properties
        fileFs; % the fs of the input, can be different from
        file_frame_length; % the frame length for the file, will be different if sr isn't the same
        file_length;
        recorder;
        
    end
    
    methods
        function obj=rt_input_file(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});
            obj.fullname='load from file';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'filename','emergency.wav');
            addParameter(pars,'foldername','.');
            addParameter(pars,'MaxFileLeveldB',100);  % how loud we assume the file to be when fully loud
            
            parse(pars,varargin{:});
            add(obj.p,param_number('MaxFileLeveldB',pars.Results.MaxFileLeveldB));
            add(obj.p,param_filename('filename',pars.Results.filename));
            add(obj.p,param_foldername('foldername',pars.Results.foldername));
            obj.input_source_type='file';
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_input(obj);
            
            close(obj);
            od=cd(getvalue(obj.p,'foldername'));
            filename=getvalue(obj.p,'filename');
            
            if ~isfile(filename)
                error('rt_input_file: file: %s doesn''t exist in folder %s\n',filename,pwd);
            end
            
            ai=audioinfo(filename);
            obj.file_length=ai.Duration;
            obj.fileFs=ai.SampleRate;
            obj.file_frame_length=calc_frame_length(obj,obj.fileFs,obj.parent.SampleRate,obj.parent.FrameLength);
            obj.recorder= dsp.AudioFileReader(filename,'PlayCount',inf,'SamplesPerFrame',obj.file_frame_length);
            cd(od);
            
            
        end
        
        function duration=get_file_duration(obj)
            duration = obj.file_length;
        end
        
        function sig=read_next(obj)
            sig = obj.recorder();
            sig=resample(sig,obj.parent.SampleRate,obj.fileFs); % ressample to wanted SR
            sig=calibrate_in(obj,sig);
        end
             
        function close(obj)
            if ~isempty(obj.recorder) % first release the old one
                release(obj.recorder);
            end
        end
            
        function sig=calibrate_in(obj,sig)
            maxdb=getvalue(obj.p,'MaxFileLeveldB');
            maxamp=obj.P0*power(10,maxdb/20);
            calib=20*log10(maxamp); % how many more dB because of pressure in Pascal        
            fac=power(10,(calib+obj.parent.input_gain)/20);
            sig=sig.*fac;
        end
        
    end
end
