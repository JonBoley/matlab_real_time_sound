%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_spectrum_lpc < rt_spectrum
    
    properties
        f1;
        f2;
        f3;
    end
    
    methods
        function obj=rt_spectrum_lpc(parent,varargin)  %init
            obj@rt_spectrum(parent,varargin{:});
            obj.fullname='Spectrogram with formants';
%             obj.show=1;
        
            s='shows the spectrogram underneath and an estimate of the first three formants on top';
            obj.descriptor=s;
        end
        
        
        
        function obj=post_init(obj) % called the second times around
            post_init@rt_spectrum(obj);
            obj.f1=circbuf1(getlength(obj.spec_buffer));
            obj.f2=circbuf1(getlength(obj.spec_buffer));
            obj.f3=circbuf1(getlength(obj.spec_buffer));
        end
        
        
        function plot(obj,sig)
            ax=obj.viz_axes;
            set(ax,'NextPlot','replaceall');
            plot@rt_spectrum(obj,sig);
            hold(ax,'on')
 
            fs=obj.parent.SampleRate;
            sig=resample(sig,7418,fs);
            
            x1 = sig.*hamming(length(sig));
            preemph = [1 0.63];
            x1 = filter(1,preemph,x1);
            A = lpc(x1,8);
            rts = roots(A);
            
            rts = rts(imag(rts)>=0);
            angz = atan2(imag(rts),real(rts));
            
            [frqs,indices] = sort(angz.*(obj.parent.SampleRate/(2*pi)));
            bw = -1/2*(obj.parent.SampleRate/(2*pi))*log(abs(rts(indices)));
            
            nn = 0;form=zeros(10);
            for kk = 1:length(frqs)
                if (frqs(kk) > 90 && bw(kk) <400)
                    nn = nn+1;
                    form(nn) = frqs(kk);
                    if nn>=10
                        break
                    end
                end
            end
            if nn>=3 && form(1)<1000
                y1=find(form(1)>obj.freq,1,'last');
                push(obj.f1,y1);
                y2=find(form(2)>obj.freq,1,'last');
                push(obj.f2,y2);
                y3=find(form(3)>obj.freq,1,'last');
                push(obj.f3,y3);
            else
                push(obj.f1,-1);
                push(obj.f2,-1);
                push(obj.f3,-1);
            end
            xx=1:length(get(obj.f1));
            plot(ax,xx,get(obj.f1),'ro','MarkerFaceColor','r','MarkerSize',8);
            plot(ax,xx,get(obj.f2),'mo','MarkerFaceColor','m','MarkerSize',8);
            plot(ax,xx,get(obj.f3),'co','MarkerFaceColor','c','MarkerSize',8);
            view(ax,0,270);
            set(ax,'Xlim',[1 getlength(obj.spec_buffer)],'Ylim',[1 getheight(obj.spec_buffer)]);

        end
        
        function obj=change_parameter(obj)
        end
    end
end