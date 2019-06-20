%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% input module, can return signals
classdef rt_input_file_random < rt_input
    properties
        allfilenames;
        recorder;
        filename;
        file_frame_length;
        fileFs;
        file_length;
    end
    
    %   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_input_file_random(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});  % superclass contructor
            obj.fullname='load from random file'; % full name identifies it later on the screen
            
            pre_init(obj);  % add the parameter gui
            obj.input_source_type='file';
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'foldername','.');
            addParameter(pars,'MaxFileLeveldB',80);  % how loud we assume the file to be when fully loud
            parse(pars,varargin{:});
            add(obj.p,param_foldername('foldername',pars.Results.foldername));
            add(obj.p,param_number('MaxFileLeveldB',pars.Results.MaxFileLeveldB));
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_input(obj);
            dirname=getvalue(obj.p,'foldername');
            close(obj);
            
            od=cd(dirname);
            alldir=dir;
            n=0;
            for i=1:length(alldir)
                if length(alldir(i).name)>3 && isequal(lower(alldir(i).name(end-3:end)),'.wav')
                    n=n+1;
                    allrandfiles{n}=alldir(i).name;
                end
            end
            obj.allfilenames=allrandfiles;
            
            rn=randperm(length(obj.allfilenames));
            obj.filename=obj.allfilenames{rn(randi(length(rn)))};
            ai=audioinfo(obj.filename);
            obj.file_length=ai.Duration;
            obj.fileFs=ai.SampleRate;
            
            obj.file_frame_length=calc_frame_length(obj,obj.fileFs,obj.parent.SampleRate,obj.parent.FrameLength);
            obj.recorder= dsp.AudioFileReader(obj.filename,'PlayCount',1,'SamplesPerFrame',obj.file_frame_length);
            cd(od);
        end
        function duration=get_file_duration(obj)
            duration = obj.file_length;
        end
        
        function sig=read_next(obj)
            [sig,eof] = obj.recorder();
            sig=resample(sig,obj.parent.SampleRate,obj.fileFs); % ressample to wanted SR
            sig=calibrate_in(obj,sig);
            
            if eof  % load the next one
                close(obj)
                od=cd(getvalue(obj.p,'foldername'));
                rn=randperm(length(obj.allfilenames));
                obj.filename=obj.allfilenames{rn(randi(length(rn)))};
                obj.recorder= dsp.AudioFileReader(obj.filename,'PlayCount',1,'SamplesPerFrame',obj.file_frame_length);
                cd(od);
            end
        end
        
        function close(obj)
            if ~isempty(obj.recorder) % first release the old one
                release(obj.recorder);
            end
        end
        
        function sig=calibrate_in(obj,sig)
            maxdb=getvalue(obj.p,'MaxFileLeveldB');
            maxamp=obj.P0*power(10,maxdb/20);
            calib=20*log10(maxamp/1); % how many more dB because of pascale
            
            fac=power(10,(calib+obj.parent.input_gain)/20);
            sig=sig.*fac;
        end
        
        
    end
end
