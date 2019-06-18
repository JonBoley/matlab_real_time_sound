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
            fitlist={'1/2 gain';'NAL'};
            addParameter(pars,'FittingMethod',fitlist{1});
            addParameter(pars,'CentreFrequencies','250,500,1000,2000,4000');
            addParameter(pars,'Audiogram','0,10,20,30,40');
            
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
            add(obj.p,param_popupmenu('FittingMethod',pars.Results.FittingMethod,'list',fitlist));
            auds=parse_csv(pars.Results.Audiogram);
            add(obj.p,param_audiogram('Audiogram',auds,'frequencies',freqs));
            
            
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
            
            fitting_method=getvalue(obj.p,'FittingMethod');
            
            if has_changed(obj.p)    % user can change the audiogram
                audithreshs=getvalue(obj.p,'Audiogram');
                if has_changed(obj.p,'Audiogram')
                    for i=1:length(audithreshs)
                        comp=getparameter(obj.p,obj.pname{i});
                        prevval=getvalue(comp);
                        cvals=comp_fit(fitting_method,audithreshs(i),prevval);
                        setvalue(comp,cvals);
                    end
                end
                
                    for i=1:length(obj.pname)
                        if has_changed(obj.p,obj.pname{i}) % user can also cahnge the individual compressors!
                            comp=getparameter(obj.p,obj.pname{i});
                            val=getvalue(comp);
                            thresh=audi_fit(fitting_method,val(3)); % the new threshold of hearing (from the compressor) is the make up gain
                            audithreshs(i)=thresh;
                            setvalue(obj.p,'Audiogram',audithreshs);
                        end
                    end
                        
                    
                    set_changed_status(obj.p,0); % pretend nothing happend.
                end
                
                
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
    
    
    % function to determine theshold settings from the compressor
    function gval=audi_fit(fitting_method,gain)
    switch fitting_method
        case '1/2 gain'
            gval=2*gain;
    end
    end
    
    % function to determine compressor settings from the gain (and previous
    % compressor setting)
    function cvals=comp_fit(fitting_method,hearthresh,prevval)
    if nargin==2
        %TODO: initial settiongs, compthreshold =-50;
    end
    
    switch fitting_method
        case '1/2 gain'
            prevknee=comp2knee(prevval(1),prevval(2));
            gain=hearthresh/2;  % this is the 1/2 rule
            newknew(1)=prevknee(1); % knew kneex=old kneex
            newknew(2)=gain+newknew(1); %
            
            [thresh,ratio,makeup]=knee2comp(newknew);
            if ratio>100
                ratio=100;
            end
            if ratio<1
                ratio=1;
            end
            if thresh<-50
                thresh=-50;
            end
            if thresh>0
                thresh=0;
            end
            cvals(1)= thresh;  % compressor threshold remaines unchanged.
            cvals(2)= ratio;  % ratio
            cvals(3)= makeup;  % make up gain
    end
    end
    
    
    % translates kneepoint data to threshold and ratio
    function [thresh,ratio,makeup]=knee2comp(k)
    maxp=100;
    thresh=-maxp+k(1);
    ratio=-thresh/(maxp-k(2));
    makeup=(k(2)-k(1));
    end
    
    % translates threshold and ratio to kneepoint
    function k=comp2knee(thresh,ratio)
    maxp=100;
    k(1)=maxp+thresh;
    k(2)=maxp+thresh/ratio;
    end
    
    
