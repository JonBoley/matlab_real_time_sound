
classdef rt_straightvoc < rt_manipulator
    properties
    end
    
    methods
        
        function obj=rt_straightvoc(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Straight Vocoder';
            pre_init(obj);  % add the p if nargin<2
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'PitchStretch',1);
            addParameter(pars,'FrequencyStretch',1);
            addParameter(pars,'TimeStretch',1);
            
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            
            add(obj.p,param_float_slider('PitchStretch',pars.Results.FrequencyStretch,'minvalue',0.1,'maxvalue',3));
            add(obj.p,param_float_slider('FrequencyStretch',pars.Results.FrequencyStretch,'minvalue',0.1,'maxvalue',3));
            add(obj.p,param_float_slider('TimeStretch',pars.Results.FrequencyStretch,'minvalue',0.1,'maxvalue',1));
            
            obj.descriptor='implementation of the STRAIGHT vocoder by Hideki Kawahara. Code modified for real time from https://github.com/HidekiKawahara/legacy_STRAIGHT';
            
            obj.requires_frame_length=1024;
        end
        
        function obj=post_init(obj) % called the second times around
            
            
            
        end
        
        function vocodedsig=apply(obj,orgsig)
            
            if obj.parent.FrameLength<1024
                disp('frame length must be at least 1024');
                vocodedsig=zeros(size(orgsig));
                return
            end
            
            f0floor=40;
            f0ceil=800;
            fs=obj.parent.SampleRate;	% sampling frequency (Hz)
            shiftm=1;       % default frame shift (ms) for spectrogram
            f0shiftm=1;     % default frame shift (ms) for F0 information
            fftl=2048;	% default FFT length
            eta=1.4;        % time window stretch factor
            pc=0.6;         % exponent for nonlinearity
            mag=0.2;      % This parameter should be revised.
            
            
            delsp=0.5; 	%  standard deviation of random group delay in ms 26/June/2002
            gdbw=70; 	% smoothing window length of random group delay (in Hz)
            cornf=4000;  	% corner frequency for random phase (Hz) 26/June 2002
            delfrac=0.2;  % This parameter should be revised.
            delfracind=0;
            xold=orgsig*32768;
            
            
            %% analyse source
            nvo=24;
            nvc=ceil(log(f0ceil/f0floor)/log(2)*nvo);
            grafix=0;
            [f0v,vrv,dfv,~,aav]=fixpF0VexMltpBG4(xold,fs,f0floor,nvc,nvo,1.2,grafix,shiftm,1,5,0.5,1);
            [pwt,pwh]=plotcpower(xold,fs,shiftm,grafix);
            [f0raw,irms,~,~]=f0track5(f0v,vrv,dfv,pwt,pwh,aav,shiftm,grafix);
            dn=floor(fs/(f0ceil*3*2));
            [f0raw,~]=refineF06(decimate(xold,dn),fs/dn,f0raw,1024,1.1,3,f0shiftm,1,length(f0raw),grafix); % 31/Aug./2004
            f0t=f0raw;
            
            f0t(f0t==0)=f0t(f0t==0)*NaN;tt=1:length(f0t);
            
            %---------- This part is for maintaining compatibility with old synthesis routine ----
            f0var=max(0.00001,irms).^2;
            f0var(f0var>0.99)=f0var(f0var>0.99)*0+100;
            f0var(f0raw==0)=f0var(f0raw==0)*0+100;
            f0var=f0var/2;  %  2 is a magic number. If everything is OK, it should be 1.
            f0var=(f0var>0.9);  % This modification is to make V/UV decision crisp  (18/July/1999)
            f0varL=f0var;
            
            f0raw(f0raw<=0)=f0raw(f0raw<=0)*0; % safeguard 31/August/2004
            f0raw(f0raw>f0ceil)=f0raw(f0raw>f0ceil)*0+f0ceil; % safeguard 31/August/2004
            
            
            %% analyze 1CHX
            [n2sgrambk,~]=straightBodyC03ma(xold,fs,shiftm,fftl,f0raw,f0var,f0varL,eta,pc,grafix); %%
            n3sgram=specreshape(fs,n2sgrambk,eta,pc,mag,f0raw,grafix);
            
            
            %% synthesize
            %             pcnv=1.5; 	% pitch stretch
            %             fconv=1.0; 	% frequency stretch
            %             sconv=1; 	% time stretch
            pcnv=getvalue(obj.p,'PitchStretch');
            fconv=getvalue(obj.p,'FrequencyStretch');
            sconv=getvalue(obj.p,'TimeStretch');
            
            
            
            sy=straightSynthTB06(n3sgram,f0raw,f0var,f0varL,shiftm,fs, ...
                pcnv,fconv,sconv,gdbw,delfrac,delsp,cornf,delfracind);
            dBsy=powerchk(sy,fs,15);
            cf=(20*log10(32768)-22)-dBsy;
            
            vocodedsig=sy*(10.0.^(cf/20));
            vocodedsig(isnan(vocodedsig))=0;
            vocodedsig=[vocodedsig;zeros(length(orgsig)-length(vocodedsig),1)];
            vocodedsig=vocodedsig/100000;
        end
        
    end
    
end