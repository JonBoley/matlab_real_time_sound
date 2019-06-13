%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef rt_hearingaid < rt_manipulator
    properties
        nr_bands;
        myoctbandfilter;
        mycompressors;
        tattack
        trelease
        pname;
    end
    
    methods
        function obj=rt_hearingaid(parent,varargin)  %init
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Hearing aid';
            pre_init(obj);  % add the parameter gui
            
            
            % first go: check for the frequencies.
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'CentreFrequencies','250,500,1000,2000,4000');
            %             comp='-20,2,'; % default compressor settings
            %             addParameter(pars,'CompressorSettings',[comp,comp,comp,comp,comp]);
            addParameter(pars,'AttackTime',0.05);
            addParameter(pars,'ReleaseTime',0.100);
            parse(pars,varargin{:});
            add(obj.p,param_generic('CentreFrequencies',pars.Results.CentreFrequencies));
            add(obj.p,param_float('AttackTime',pars.Results.AttackTime,'unit','sec','unittype',unit_time));
            add(obj.p,param_float('ReleaseTime',pars.Results.ReleaseTime,'unit','sec','unittype',unit_time));
            
            % second go: make all  compressors:
            freqs=parse_csv(getvalue(obj.p,'CentreFrequencies'));
            pars2 = inputParser;
            pars2.KeepUnmatched=true;
            for i=1:length(freqs)
                obj.pname{i}=sprintf('band%d_%3.0fHz',i,freqs(i));
                addParameter(pars,obj.pname{i},[-20,2]); %default value for compressors
            end
            parse(pars,varargin{:});
            for i=1:length(freqs)
                eval(sprintf('compset=pars.Results.%s;',obj.pname{i}));
                s=sprintf('pp=param_compressor(''%s'',[%f,%f],''maxamplitude'',[%f,%f]);',obj.pname{i},compset(1),compset(2),obj.MAXVOLUME,obj.MAXVOLUME);
                eval(s);
                add(obj.p,pp);
            end
            
            %             add(obj.p,param_audiogram('Audiogram',pars.Results.Audiogram));
            
            
            s='Hearing aid module simulates a simple hearing aid consisting of several stages:';
            s=[s,'a set of bandpass filters splits the signal into different bands. The number of bands is defined by the parameter "bands"'];
            s=[s,'each band has a compressor that reduces the dynamic range and amplifies all sounds below the knee point'];
            obj.descriptor=s;
            
        end
        
        
        function post_init(obj) % called the second times around
            post_init@rt_manipulator(obj);
            
            freqs=parse_csv(getvalue(obj.p,'CentreFrequencies'));
            obj.nr_bands=length(freqs);
            
            N=6; % filter order
            BW = '1 octave';  % one octave filter
            for i=1:obj.nr_bands
                obj.myoctbandfilter{i} = octaveFilter('FilterOrder', N,'CenterFrequency', freqs(i), 'Bandwidth', BW, 'SampleRate',  obj.parent.SampleRate);
                compvals=getvalue(obj.p,obj.pname{i});
                
                obj.mycompressors{i} = compressor(compvals(1),compvals(2),...
                    'KneeWidth',0,...
                    'SampleRate',obj.parent.SampleRate,...
                    'MakeUpGainMode','Property',...
                    'MakeUpGain',0);
            end
            
            %% if overlap and add, there exist another module that needs to be updated too!!            % make sure that the other module doesn't get forgotton:
            sync_initializations(obj); % in order to catch potential other modules that need to be updated!
            
        end
        
        function out=apply(obj,in)
            outc=zeros(length(in),obj.nr_bands);
            % calibration: matlab doesn't know about p0, it calculates dB
            % as xdB=20*log10(abs(in)). Our signals are in dBSPL, so we
            % need to multiply by log10(p0) and our zero point is the
            % maximum level (100dB) so we need to add that up
            %             const=20*log10(obj.P0);
            const= power(10,obj.MAXVOLUME/20)*obj.P0;
            in=in/const;
            
            tauA=getvalue(obj.p,'AttackTime','sec');
            tauR=getvalue(obj.p,'ReleaseTime','sec');
            %% ocatve band filtering
            for i=1:obj.nr_bands
                %             for i=3:3
                r=getvalue(obj.p,obj.pname{i});
                obj.mycompressors{i}.Threshold=max(-50,r(1));
                obj.mycompressors{i}.Ratio=max(1,r(2));
                obj.mycompressors{i}.AttackTime =tauA;
                obj.mycompressors{i}.ReleaseTime =tauR;
                obj.mycompressors{i}.MakeUpGain =r(3);
                %
                outf= step(obj.myoctbandfilter{i},in);
                [outc(:,i),g] = step(obj.mycompressors{i},outf);
            end
            %
            %             %% sum channels into the right format
            out=sum(outc')';
            %             out=outc(:,3);
            out=out*const;
            %             visualize(dRC);
            
            %             figure(1)
            %             clf,hold on
            %             %                         plot(outc);
            %
            %             plot(in,'b')
            %             %             plot(outf,'g')
            %             plot(out,'r')
            %             %             plot(g,'c')
            %             fprintf('in: %3.0fdB - out: %3.1fdB\n',20*log10(rms(in(2:end))),20*log10(rms(out(2:end))));
            
        end
        
    end
end


