%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_ncm < rt_measurer
    properties
        noisy_buffer;
        ncm_buffer;
        clean_buffer
    end
    
    methods
        %% creator
        function obj=rt_ncm(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='NCM';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'integrationPeriod',0.5);  % buffer for computation MUST be >0.4 sec!
            parse(pars,varargin{:});
            add(obj.p,param_float('integrationPeriod',pars.Results.integrationPeriod));
            
            s='estimation of speech intellegibility using  normalized covariance metric.';
            s=[s, 'and requires the clean signal'];
            s=[s, 'Reference'];
            s=[s, '[1]  Ma, J., Hu, Y. and Loizou, P. (2009). "Objective measures for'];
            s=[s, 'predicting speech intelligibility in noisy conditions based on new band-importance'];
            s=[s, 'functions", Journal of the Acoustical Society of America, 125(5), 3387-3405.'];
            s=[s, 'Authors:  Fei Chen and Philipos C. Loizou '];
            s=[s, 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2806444/'];
            obj.descriptor=s;
            
            
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            
            l=getvalue(obj.p,'integrationPeriod');
            
            obj.clean_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            obj.noisy_buffer=circbuf1(l*obj.parent.SampleRate);  % 1 sec
            m=round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength);
            mm=max(m,1);
            obj.ncm_buffer=circbuf1(mm);
        end
        
        function ncm_val=calculate(obj,sig)
            fs=obj.parent.SampleRate;
            
            push(obj.clean_buffer,obj.parent.clean_stim);
            push(obj.noisy_buffer,sig);
            
            ref_data=get(obj.clean_buffer);
            deg_data=get(obj.noisy_buffer);
            
            %             Sampling frequency for NCM needs to be either 8000 or 16000 Hz
            ref_data=resample(ref_data,16000,fs);
            deg_data=resample(deg_data,16000,fs);
            
            ncm_val= NCM(ref_data, deg_data,16000);
            
            push( obj.ncm_buffer,ncm_val);
            
            x=1:getlength(obj.ncm_buffer);
            y=get(obj.ncm_buffer);
            measax=obj.measurement_axis;
            plot(measax,x,y,'.-');
                         set(measax,'xlim',[0 length(x)],'ylim',[0 0.5]);

        end
        
        function close(obj)
        end
        
    end
end


