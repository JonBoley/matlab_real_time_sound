
classdef rt_lpc < rt_measurer
    
    properties
        myGUIdata
        sigbuffer;
    end
    
    methods
        function obj=rt_lpc(parent,varargin)  %init
            obj@rt_measurer(parent,varargin{:});  % superclass contructor
            obj.fullname='Linear Predictive Coefficients (LPC)'; % full name identifies it later on the screen
            pre_init(obj);  % add the parameter gui
                  
            s='Linear Predictive Coefficients (LPC) ';
            s=[s,'implemenation from Hideki Kawahara from github: https://github.com/HidekiKawahara'];
            s=[s,'more information here: https://en.wikipedia.org/wiki/Linear_predictive_coding'];
            s=[s,''];
            s=[s,'matlab uses the function https://uk.mathworks.com/help/signal/ref/lpc.html'];
            obj.descriptor=s;   
        end
        
        function obj=post_init(obj)
            post_init@rt_measurer(obj);
%             figure(1);
            myGUIdata.samplingFrequency = 8000; % in Hz
            myGUIdata.windowLength = obj.parent.FrameLength/obj.parent.SampleRate; % in second
            myGUIdata.windowLengthInSamples = round(obj.parent.FrameLength);% *8000/obj.parent.Fs);
            myGUIdata.fftl = 256;
            
            w = blackman(myGUIdata.windowLengthInSamples);
            w = w/sqrt(sum(w.^2));
            myGUIdata.window = w;
            
            mmax=obj.measurement_axis;
            
%             subplot(2,2,3);
            fs = myGUIdata.samplingFrequency;
            myGUIdata.displayFrequencyAxis = (0:myGUIdata.fftl-1)/myGUIdata.fftl*fs;
            tt = (1:myGUIdata.windowLengthInSamples)'/fs;
            %x = randn(myGUIdata.windowLengthInSamples,1);
            x = sin(2*pi*440*tt);
            pw = 10*log10(abs(fft(x.*w,myGUIdata.fftl)).^2/myGUIdata.fftl);
            plot(mmax,myGUIdata.displayFrequencyAxis,pw);
            hold(mmax,'on');
            plot(mmax,myGUIdata.displayFrequencyAxis,pw,'r','linewidth',2);
            grid(mmax,'on');
            axis(mmax,[0 fs/2 -110 0]);
            set(mmax,'fontsize',14,'linewidth',2);
            xlabel(mmax,'frequency (Hz)')
            ylabel(mmax,'level (dB rel. MSB)');
%             legend(mmax,'power spectrum','14th order LPC');
                        hold(mmax,'off');

            obj.sigbuffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth)); %zeros(pa
            obj.myGUIdata=myGUIdata;
            
        end
        
        function lpcback=calculate(obj,sig)
            
            sig=resample(sig,8000,obj.parent.SampleRate);
            
            myGUIdata=obj.myGUIdata;
            w = myGUIdata.window;
            numberOfSamples = length(w);
            
            push(obj.sigbuffer,sig);
            tmp=get(obj.sigbuffer);
            tmpAudio=tmp(end-length(w):end);

            currentPoint = length(tmpAudio);
            x = tmpAudio(currentPoint-numberOfSamples+1:currentPoint);
            pw = abs(fft(x.*w,myGUIdata.fftl)).^2/myGUIdata.fftl;
            pwdB = 10*log10(pw);
           
            mmax=obj.measurement_axis;

            ac = real(ifft(pw));
            [alp,err,k] = levinson(ac,14);
            env = 1.0./abs(fft(alp,myGUIdata.fftl)).^2;
            env = sum(pw)*env/sum(env);
            envDB = 10*log10(env);
            
            plot(mmax,myGUIdata.displayFrequencyAxis,pwdB,myGUIdata.displayFrequencyAxis,envDB,'r','linewidth',2);
%             legend(mmax,'power spectrum','14th order LPC');

            lpcback=alp;
            
        end
        
        function obj=change_parameter(obj)
        end
    end
    
end
