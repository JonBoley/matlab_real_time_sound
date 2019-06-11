%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_pitch < rt_measurer
    properties
        pitch_buffer;
        stim_buffer;
        myPitch;
        integration_length;
    end
    
    methods
        %% creator
        function obj=rt_pitch(parent,varargin)
            obj@rt_measurer(parent,varargin);
            obj.fullname='Pitch estimation';
            pre_init(obj);  % add the parameter gui
            
            algorithms = {'NCF - Normalized Correlation Function';...
                'PEF - Pitch Estimation Filter';...
                'CEP - Cepstrum Pitch Determination';...
                'LHS - Log-Harmonic Summation';...
                'SRH - Summation of Residual Harmonics'};
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'algorithm',algorithms{1});
            addParameter(pars,'OverlapLength',1);
            addParameter(pars,'WindowLength',1);
            addParameter(pars,'Range',[50,400]);
            addParameter(pars,'MedianFilterLength',1);
            
            parse(pars,varargin{:});
            add(obj.p,param_popupmenu('algorithm',pars.Results.algorithm,'list',algorithms));
            add(obj.p,param_number('OverlapLength',pars.Results.OverlapLength));
            add(obj.p,param_number('WindowLength',pars.Results.WindowLength));
            add(obj.p,param_twonumbers('Range',pars.Results.Range));
            add(obj.p,param_number('MedianFilterLength',pars.Results.MedianFilterLength));
            
            s='pitch estimates the fundamental frequeny';
            s=[s,'implementation from the matlab function ''pitch'' described here:'];
            s=[s, 'https://uk.mathworks.com/help/audio/ref/pitch.html'];
            obj.descriptor=s;
 
            
            
        end
        
        function post_init(obj)
            post_init@rt_measurer(obj);
            OverlapLength=round(obj.parent.SampleRate*0.042);
            setvalue(obj.p,'OverlapLength',OverlapLength);
            WindowLength=round(obj.parent.SampleRate*0.052);
            setvalue(obj.p,'WindowLength',WindowLength);
            
            obj.stim_buffer=circbuf1(obj.parent.SampleRate);  % 1 sec
            obj.pitch_buffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth/obj.parent.FrameLength));
            % buffer for computation MUST be >0.4 sec!
            obj.integration_length=0.1;
            
        end
        
        function f0=calculate(obj,sig)
            
%             if has_changed(obj.p)
%                 p1=getparameter(obj.p,'algorithm');
%                 p2=getparameter(obj.p,'lowest_frequency');
%                 p3=getparameter(obj.p,'highest_frequency');
%                 if has_changed(p1) || has_changed(p2)|| has_changed(p3)
%                     post_init(obj);
%                     set_changed_status(obj.p,0);
%                 end
%             end
            
%   Copyright 2019 Stefan Bleeck, University of Southampton
            
            
            push(obj.stim_buffer,sig); %push the short sig into the buffer
            longsig=get(obj.stim_buffer); % get the whole signal out for analysis
            
            method=getvalue(obj.p,'algorithm');
            method=method(1:3);
            OverlapLength=getvalue(obj.p,'OverlapLength');
            WindowLength=getvalue(obj.p,'WindowLength');
            Range=getvalue(obj.p,'Range');
            MedianFilterLength=getvalue(obj.p,'MedianFilterLength');
            
            fs=obj.parent.SampleRate;
            l=round(WindowLength/OverlapLength);
            l=WindowLength;
            anasig=longsig(end-l:end);
            
            
            [f0,~] = pitch(anasig,fs, ...
                'Method',method,...
                'MedianFilterLength',3,...
                'OverlapLength',OverlapLength,...
                'WindowLength',WindowLength,...
                'Range',Range,...
                'MedianFilterLength',MedianFilterLength);
            
            
            push(obj.pitch_buffer,f0);
            
            x=1:getlength(obj.pitch_buffer);
            y=get(obj.pitch_buffer)';
            xx=x(y<Range(2));
            yy=y(y<Range(2));
            xxx=xx(yy>Range(1));
            yyy=yy(yy>Range(1));
            measax=obj.measurement_axis;
            plot(measax,xxx,yyy,'o','markersize',10,'markerfacecolor','b');
            set(measax,'ylim',Range);
            
        end
        
        
        function change_parameter(obj)
            gui(obj.p);
            post_init(obj);
            
        end
    end
end


