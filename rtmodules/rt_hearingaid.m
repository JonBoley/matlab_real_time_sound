%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef rt_hearingaid < rt_manipulator
    properties
        nr_bands;
        myoctbandfilter;
        mycompressors;
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
            
            s='Hearing aid module simulates a simple hearing aid consisting of several stages:';
            s=[s, ' a set of bandpass filters splits the signal into different bands. The number of bands is defined by the parameter "bands"'];
            s=[s, 'each band has a compressor that reduces the dynamic range and amplifies all sounds below the knee point'];
            obj.descriptor=s;
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_manipulator(obj);
            
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
                    'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', Fs);
            end
            obj.myoctbandfilter=fullOctaveFilterBank;
            
            m='[';
            for i=1:3
                m=[m sprintf('%d %d',vcomp(i,1),vcomp(i,2))];
                if i<3
                    m=[m ';'];
                end
            end
            m=[m ']'];
            
            for i=1:obj.nr_bands
                name=sprintf('band %d - %3.0fHz',i,F0(i));
                s=sprintf('obj.pams{%d}=param_mouse_panel(''%s'',%s,''compressor'');',i,name,m);
                eval(s);
                add(obj.p,obj.pams{i});
            end
            getvalue(obj.p,sprintf('band %d - %3.0fHz',i,F0(i)));
            
            
            add(obj.p,param_number('attack time (sec)',0.05));
            add(obj.p,param_number('release time (sec)',0.1));
            
            for i=1:obj.nr_bands
                dRC{i} = compressor(-20,2,...
                    'KneeWidth',0,...
                    'SampleRate',Fs,...
                    'MakeUpGainMode','Auto');
            end
            %             visualize(dRC);
            obj.mycompressors=dRC;
            
            
            %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
            sync_initializations(obj); % in order to catch potential other modules that need to be updated!
            
        end
        
        function out=apply(obj,in)
            outf=zeros(obj.nr_bands,length(in));
            %% ocatve band filtering
            for i=1:obj.nr_bands
                outf(i,:)= step(obj.myoctbandfilter{i},in);
            end
            outc=outf; % memory allocation
            
            %% compression
            [thresh,ratio,tauA,tauR]=getcurrentvals(obj); % get the values from the open GUI
            
            for i=1:obj.nr_bands
                obj.mycompressors{i}.Threshold=thresh(i);
                obj.mycompressors{i}.Ratio=ratio(i);
                obj.mycompressors{i}.AttackTime =tauA;
                obj.mycompressors{i}.ReleaseTime =tauR;
%                 obj.mycompressors{i}.MakeUpGainMode ='Property';
                outc(i,:) = step(obj.mycompressors{i},outf(i,:));
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

    end
end


