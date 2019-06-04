

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
            obj.show=1;  % show me as selectable to the user
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'directory','.');
            parse(pars,varargin{:});
            add(obj.p,param_foldername('directory',pars.Results.directory));
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_input(obj);
            dirname=getvalue(obj.p,'directory');
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
            sig=input_calibrate(obj,sig);
            
            if eof  % load the next one
                close(obj)
                od=cd(getvalue(obj.p,'directory'));
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
    end
end
