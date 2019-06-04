


classdef rt_space < rt_manipulator
    properties
        elevation=inf;
        angle=inf;
        hrtfleft;
        hrtfright;
        stimbuf;
    end
    
    methods
        
        function obj=rt_space(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Head related transfer function';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            %             addParameter(pars,'WetDryMix',0.3);
            parse(pars,varargin{:});
            %             add(obj.p,param_float_slider('WetDryMix',pars.Results.WetDryMix,'minvalue',0, 'maxvalue',1));
            
        end
        
        function post_init(obj) % called the second times around
            obj.stimbuf=circbuf1(obj.parent.SampleRate/10);  % 1 sec
        end
        
        function new_sig=apply(obj,sig)
            % take the first channel and apply the two relevant HRTFs to
            % simulate
            mychannel=obj.channel_nr;  % 1=left, 2=right
            
            % we are producing two channels out of one. We assume the first
            % channel coming in as the input.
            dir1='rtmodules/hrtfs';
            
            newelevation=0;
            newangle=90;
            if newelevation~=obj.elevation || newangle ~= obj.angle
                switch mychannel
                    case 1
                        lhname=sprintf('L%de%3da.wav',newelevation,newangle);
                        lhtrffilename=strrep(lhname,' ','0');
                        obj.hrtfleft=audioread(fullfile(dir1,lhtrffilename));
                    case 2
                        rhname=sprintf('R%de%3da.wav',newelevation,newangle);
                        rhtrffilename=strrep(rhname,' ','0');
                        obj.hrtfright=audioread(fullfile(dir1,rhtrffilename));
                end
            end
            
            push(obj.stimbuf,sig);
            s=get(obj.stimbuf,512); % the length of the hrtfs
            
            switch mychannel
                case 1
                    convded=conv(s,obj.hrtfleft,'same');
                case 2
                    convded=conv(s,obj.hrtfright,'same');
            end
            
            new_sig(:,1)=convded(1:256);
            
        end
        
        function change_parameter(obj)
            gui(obj.p)
        end
    end
    
end