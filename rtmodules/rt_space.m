%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef rt_space < rt_manipulator
    properties
        elevation=inf;
        angle=inf;
        hrtfleft;
        hrtfright;
        stimbuf;
        sourcePosition
        hrtfData
        desiredPosition
        leftFilter
        rightFilter
    end
    
    methods
        
        function obj=rt_space(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Head related transfer function';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            addParameter(pars,'azimuth',0);
            addParameter(pars,'elevation',0);
            
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('azimuth',pars.Results.elevation,'minvalue',-180, 'maxvalue',180));
            add(obj.p,param_float_slider('elevation',pars.Results.elevation,'minvalue',0, 'maxvalue',90));
            
            s='Head related transfer function (HRTF) takes the input from ONE channel and calculates how ';
            s=[s,'it would sound when it comes from a specific point in space. It uses the knowledge of'];
            s=[s,'the shape of the outer ear as well as interaural time and level differences'];
            s=[s,'the implementation is by S.Bleeck and uses the hrtfs from a public databse:'];
            obj.descriptor=s;
            
            obj.requires_nr_channels=2; % we need 2 channels!
            obj.requires_version='R2018b';
            obj.requires_toolbox='Audio Toolbox';
        end
        
        function post_init(obj) % called the second times around
            if obj.parent.Channels<2
                disp('SRTFs need 2 channels');
                return
            end
            obj.stimbuf=circbuf1(obj.parent.SampleRate/10);  % 1 sec
            
            load 'ReferenceHRTF.mat' hrtfData sourcePosition
            obj.hrtfData = permute(double(hrtfData),[2,3,1]);
            obj.sourcePosition = sourcePosition(:,[1,2]);
            
        end
        
        function new_sig=apply(obj,sig)
            % take the first channel and apply the two relevant HRTFs to
            % simulate
            mychannel=obj.channel_nr;  % 1=left, 2=right
            
            desiredAz = getvalue(obj.p,'azimuth');
            desiredEl = getvalue(obj.p,'elevation');
            desiredPos = [desiredAz desiredEl];
            
            if ~isequal(desiredPos,obj.desiredPosition)
                obj.desiredPosition=desiredPos;
                interpolatedIR  = interpolateHRTF(obj.hrtfData,obj.sourcePosition,obj.desiredPosition,"Algorithm","VBAP");
                leftIR = squeeze(interpolatedIR(:,1,:))';
                rightIR = squeeze(interpolatedIR(:,2,:))';
                obj.leftFilter = dsp.FIRFilter('Numerator',leftIR);
                obj.rightFilter = dsp.FIRFilter('Numerator',rightIR);
            end
                        
            switch mychannel
                case 1
                    convded = obj.leftFilter(sig);
                case 2
                    convded = obj.rightFilter(sig);
            end
            new_sig(:,1)=convded(1:256);
            
            %
            %                 % we are producing two channels out of one. We assume the first
            %                 % channel coming in as the input.
            %                 dir1='thirdparty/hrtfs';
            %
            %                 newelevation=getvalue(obj.p,'elevation');
            %                 if newelevation ~=0
            %                     disp('elevation only implemented for 0 degrees, sorry')
            %                     newelevation=0;
            %                 end
            %
            %                 angle=getvalue(obj.p,'azimuth');
            %                 newangle=5*round(angle/5);
            %                 newangle=180-newangle;
            %                 if newangle==360
            %                     newangle=0;
            %                 end
            %
            %
            %                 if newelevation~=obj.elevation || newangle ~= obj.angle
            %                     switch mychannel
            %                         case 1
            %                             lhname=sprintf('L%de%3da.wav',newelevation,newangle);
            %                             lhtrffilename=strrep(lhname,' ','0');
            %                             obj.hrtfleft=audioread(fullfile(dir1,lhtrffilename));
            %                         case 2
            %                             rhname=sprintf('R%de%3da.wav',newelevation,newangle);
            %                             rhtrffilename=strrep(rhname,' ','0');
            %                             obj.hrtfright=audioread(fullfile(dir1,rhtrffilename));
            %                     end
            %                     obj.elevation=newelevation;
            %                     obj.angle=newangle;
            %                 end
            %
            %                 push(obj.stimbuf,sig);
            %                 s=get(obj.stimbuf,512); % the length of the hrtfs
            %
            %                 switch mychannel
            %                     case 1
            %                         convded=conv(s,obj.hrtfleft,'same');
            %                     case 2
            %                         convded=conv(s,obj.hrtfright,'same');
            %                 end
            %
            %                 new_sig(:,1)=convded(1:256);
            
        end
        
        function change_parameter(obj)
            gui(obj.p)
        end
    end
    
end