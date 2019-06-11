%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_mfccs < rt_measurer
    properties
        mfccbuf;
        stim_buffer;
        xlab;
        mymfcc;
    end
    
    methods
        %% creator
        function obj=rt_mfccs(parent,varargin)
            obj@rt_measurer(parent,varargin{:});
            obj.fullname='MFCCs (mel frequency cepstral coefficients)';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            banks={'Mel';'Gammatone'};
            addParameter(pars,'NumCoeffs',13);
            addParameter(pars,'WindowLength',1);
            addParameter(pars,'FilterBank',banks{1});
            
            parse(pars,varargin{:});
            add(obj.p,param_popupmenu('FilterBank',pars.Results.FilterBank,'list',banks));
            add(obj.p,param_number('NumCoeffs',pars.Results.NumCoeffs));
            add(obj.p,param_number('WindowLength',pars.Results.WindowLength));
            
            s='MFCCs (mel frequency cepstral coefficients) measures features of speech that are often used in automatic speech recognition';
            s=[s,'the code is a wrapper for the matlab fuction ''cepstralfeatureextractor'''];
            s=[s,'https://uk.mathworks.com/help/audio/ref/cepstralfeatureextractor-system-object.html'];
            obj.descriptor=s;
            
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            setvalue(obj.p,'WindowLength',ceil(obj.parent.SampleRate*0.03));
            
            measax=obj.measurement_axis;
            
            numCoeef=getvalue(obj.p,'NumCoeffs');
            nrx=ceil(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            obj.mfccbuf=circbuf(nrx,numCoeef+1); % plus 1 for the log energy ('default: append), see help
            obj.stim_buffer=circbuf1(round(obj.parent.SampleRate*obj.parent.FrameLength));
            imagesc(get(obj.mfccbuf)','parent',measax);
            view(measax,0,270);
            buf=obj.mfccbuf;
            set(measax,'Xlim',[1 getlength(buf)],'Ylim',[1 getheight(buf)]);
            
            
            xt=get(measax,'xtick');
            xtt=xt/getlength(buf)*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=num2str(round(xtt(i)*10)/10);
            end
            
            obj.mymfcc=cepstralFeatureExtractor(...
                'FilterBank',getvalue(obj.p,'FilterBank'),...
                'SampleRate',obj.parent.SampleRate,...
                'NumCoeffs',getvalue(obj.p,'NumCoeffs'),...
                'InputDomain','Time');
            
        end
        
        function coeffs=calculate(obj,sig)
             if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
             end
            
            
            push(obj.stim_buffer,sig);
            asig=get(obj.stim_buffer);
            winl=getvalue(obj.p,'WindowLength');
            audsig=asig(end-winl+1:end); % get the last part
            
            [coeffs,delta,deltaDelta]=obj.mymfcc(audsig);
            
            %             [coeffs,delta,deltaDelta,loc] =mfcc(audsig,fs,'NumCoeffs',getvalue(obj.p,'NumCoeffs'),'WindowLength',winl);
            push(obj.mfccbuf,coeffs');
            
            dd=get(obj.mfccbuf);
            measax=obj.measurement_axis;
            imagesc(dd','parent',measax);
            view(measax,0,270);
            
            set(measax,'xticklabel',obj.xlab)
            
        end
        
     
    end
end

