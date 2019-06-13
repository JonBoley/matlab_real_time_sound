%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_dBSPL < rt_measurer
    properties
        dbbuffer=[];
        buffertime; % slow average over one second
        octbandfilt;
        CenterFrequency;
    end
    
    methods
        %% creator
        function obj=rt_dBSPL(parent,varargin)
            obj@rt_measurer(parent,varargin{:});
            obj.fullname='Decibel Sound Pressure Level';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            banks={'1 octave';'1/2 octave';'1/3 octave';'1/6 octave';'1/12 octave';'1/48 octave'};
            addParameter(pars,'Bandwidth',banks{1});
            
            parse(pars,varargin{:});
            add(obj.p,param_popupmenu('Bandwidth',pars.Results.Bandwidth,'list',banks));
            
            s='Sound level meter. A-level code The A-weighting filter''s coefficients';
            s=[s 'are acccording to IEC 61672-1:2002 standard from'];
            s=[s ' https://uk.mathworks.com/matlabcentral/fileexchange/46819-a-weighting-filter-with-matlab'];
            s=[s 'the module includes an octave band filter from the matlab implementation'];                      
            obj.descriptor=s;
            
        end
        
        function post_init(obj)
            
            Fs=obj.parent.SampleRate;
            
            obj.buffertime=2;
            obj.dbbuffer=circbuf1(round(Fs*obj.buffertime/obj.parent.FrameLength));
            
            N = 6;           % Filter Order
            F0 = 1000;       % Center Frequency (Hz)
            oneOctaveFilter = octaveFilter('FilterOrder', N, ...
                'CenterFrequency', F0, 'Bandwidth', getvalue(obj.p,'Bandwidth'), 'SampleRate', Fs);
            F0 = getANSICenterFrequencies(oneOctaveFilter);
            F0(F0<100) = [];
            F0(F0>20e3) = [];
            Nfc = length(F0);
            obj.octbandfilt=[];
            for i=1:Nfc
                obj.octbandfilt{i} = octaveFilter('FilterOrder', N, ...
                    'CenterFrequency', F0(i), 'Bandwidth', getvalue(obj.p,'Bandwidth'), 'SampleRate', Fs);
            end
            obj.CenterFrequency=F0;
            
            measax=obj.measurement_axis;
            if ~isempty(measax)
                cla(measax,'reset');
                hold(measax,'off')
                set(measax,'xlim',[0.5 length(obj.octbandfilt)+2.5])
                set(measax,'ylim',[0 obj.MAXVOLUME])
                xlabel(measax,'frequency (kHz)');
                ylabel(measax,'measured dB/band');
                
                for i=1:length(obj.CenterFrequency)
                    fs{i}=sprintf('%2.2f',obj.CenterFrequency(i)/1000);
                end
                fs{i+1}='total(linear)';
                fs{i+2}='total(dBA)';
                set(measax,'xtick',1:length(obj.octbandfilt)+2,'xticklabel',fs)
            end
        end
        
        
        function ret=calculate(obj,sig)
            if size(sig,2)>1  % this measurement needs to be done on only one channel
                sig=sig(:,1);
            end
            
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            
            %% db gives back two values: the
            xx=rms(sig);
            
            ret.dbinst=20*log10(xx/obj.P0);
            push(obj.dbbuffer,ret.dbinst);
            
            dbmean= 20*log10(xx/obj.P0);
            sa = filterA(sig, obj.parent.SampleRate);
            dbmeanA=rms(sa);
            dbmeanA=20*log10(dbmeanA/obj.P0);
            
            %             ret.dbslow=20*log10(mean(get(obj.dbbuffer)));
            c=zeros(size(obj.octbandfilt));
            for i=1:length(obj.octbandfilt)
                x= step(obj.octbandfilt{i},sig);
                r=rms(x);
                c(i)=20*log10(r/obj.P0);
            end
            ret.freq=obj.CenterFrequency;
            ret.fmeas=c;
            
            %     disp(sprintf('250: %2.2f dB, 500: %2.2f dB, 1K: %2.2f dB, 2K: %2.2f dB, 4K: %2.2f dB',c(1),c(2),c(3),c(4),c(5)));
            measax=obj.measurement_axis;
            if ~isempty(measax)
                for i=1:length(c)
                    cs{i}=sprintf('%3.0f',c(i));
                end
                cs{i+1}=sprintf('%3.0f',dbmean);
                cs{i+2}=sprintf('%3.0f',dbmeanA);
                c(i+1)=dbmean;
                c(i+2)=dbmeanA;
                xx=1:length(obj.octbandfilt)+2;
                plot(measax,xx,c,'-ko','markerfacecolor','k')
                text(measax,xx,c+5,cs);
                
                %             for i=1:length(obj.octbandfilt)
                %                 plot(measax,i,c(i),'ko','markerfacecolor','k')
                %                 text(measax,i,c(i)+10,sprintf('%2.1f',c(i)));
                %             end
                
            end
        end
    end
end


