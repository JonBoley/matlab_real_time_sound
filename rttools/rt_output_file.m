%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% input module, can return signals
classdef rt_output_file < rt_output
    properties
        filewriter;
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_output_file(parent,varargin) %% called the very first time around
            obj@rt_output(parent,varargin{:});
            obj.fullname='output to file';
            pre_init(obj);  % add the parameter gui
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'filename','emergencyoutput.wav');
            addParameter(pars,'foldername','.');
            parse(pars,varargin{:});
            add(obj.p,param_filename('filename',pars.Results.filename));
            add(obj.p,param_foldername('foldername',pars.Results.foldername));
            
            obj.output_drain_type='file';
%             obj.show=1;

        end
        
        function post_init(obj) % called the second times around
            post_init@rt_output(obj);
            
            od=cd(getvalue(obj.p,'foldername'));
            filename=getvalue(obj.p,'filename');
            
            if ~isfile(filename)
                fprintf('rt_input_file: file: %s doesn''t exist\nUsing emergency file ''emergencyoutput.wav'' instead',filename);
                filename='emergencyoutput.wav';
                fclose(fopen(filename, 'w'));
             end
            cd(od);
            
            obj.filewriter= dsp.AudioFileWriter(filename);
        end
        
        function write_next(obj,sig)
            obj.filewriter(sig);
        end
        
        function close(obj)
            if ~isempty(obj.filewriter) % first release the old one
                release(obj.filewriter);
            end
        end
    end
end
