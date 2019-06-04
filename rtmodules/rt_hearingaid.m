

classdef rt_hearingaid < rt_manipulator
    properties
        nr_bands;
        octbandfilt;
        compressor;
        tattack
        trelease
        maxSig
        pams;
    end
    
    methods
        function obj=rt_hearingaid(parent,varargin)  %init
           obj@rt_manipulator(parent,varargin);
            obj.fullname='Hearing aid';
            pre_init(obj);  % add the parameter gui
            
%             pars = inputParser;
%             pars.KeepUnmatched=true;
%             addParameter(pars,'gain',1);
%             parse(pars,varargin{:});
%             add(obj.p,param_slider('gain',pars.Results.gain,'minvalue',-20, 'maxvalue',20));
%             
%             
%             if nargin <2
%                 name='Hearing aid';
%             end
%             obj@manipulator(parent,name);  %% initialize superclass first
        end
        
%   Copyright 2019 Stefan Bleeck, University of Southampton
        function post_init(obj) % called the second times around
            
            obj.nr_bands=5;% Filter Order
            add(obj.p,param_number('number bands',obj.nr_bands));
            
            % default values
            vcomp=[0 20;55 65; 110 110];
            
            obj.tattack=5;
            obj.trelease=20;
            obj.maxSig = 110;% an estimate for the maximum decibel value you would ever expect as the input
            
            N=6; % filter order
            BW = '1 octave';  % one octave filter
            F0 = 1000;       % Center Frequency (Hz)
            Fs = obj.parent.SampleRate;      % Sampling Frequency (Hz)
            oneOctaveFilter = octaveFilter('FilterOrder', N, ...
                'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', Fs);
            
            F0 = getANSICenterFrequencies(oneOctaveFilter);
            F0(F0<250) = [];
            %             F0(F0>20e3) = [];
            F0=F0(1:obj.nr_bands);
            for i=1:obj.nr_bands
                fullOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
                    'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', Fs); %#ok
            end
            obj.octbandfilt=fullOctaveFilterBank;
            
            m=['['];
            for i=1:3
                m=[m sprintf('%d %d',vcomp(i,1),vcomp(i,2))];
                if i<3
                    m=[m ';'];
                end
            end
            m=[m ']'];
            
            for i=1:obj.nr_bands
                name=sprintf('band %d',i);
                s=sprintf('obj.pams{%d}=param_mouse_panel(''%s'',%s,''compressor'');',i,name,m);
                eval(s);
                add(obj.p,obj.pams{i});
            end
            getvalue(obj.p,'band 1')
            
            
            add(obj.p,param_number('attack time (sec)',0.05));
            add(obj.p,param_number('release time (sec)',0.1));
            
            for i=1:obj.nr_bands
                dRC{i} = compressor(-20,2,...
                    'KneeWidth',0,...
                    'SampleRate',Fs,...
                    'MakeUpGainMode','Auto');
            end
            %             visualize(dRC);
            obj.compressor=dRC;
            
            
                        %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!

        end
        
        function out=apply(obj,in)
            outf=zeros(obj.nr_bands,length(in));
            %% ocatve band filtering
            for i=1:obj.nr_bands
                outf(i,:)= step(obj.octbandfilt{1},in);
            end
            
            outc=outf; % memory allocation
            
            %% compression
            [thresh,ratio,tauA,tauR]=getcurrentvals(obj); % get the values from the open GUI
            
            for i=1:obj.nr_bands
                obj.compressor{i}.Threshold=thresh(i);
                obj.compressor{i}.Ratio=ratio(i);
                obj.compressor{i}.AttackTime =tauA;
                obj.compressor{i}.ReleaseTime =tauR;
                
                outc(i,:) = step(obj.compressor{i},outf(i,:));
            end
            
            %% sum channels into the right format
            out=sum(outc);
            out=out';
            
        end
        
        
        function [thresh,ratio,tauA,tauR]=getcurrentvals(obj)
            for i=1:obj.nr_bands
                [thresh(i),ratio(i)]=getcompressorvalues(obj.pams{i});
            end
            tauA=getvalue(obj.p,'attack time (sec)');
            tauR=getvalue(obj.p,'release time (sec)');
        end
        
        
        function close(obj)
        end
    end
end


