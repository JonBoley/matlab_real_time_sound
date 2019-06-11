
classdef rt_vtl < rt_visualizer
    
    properties
        myGUIdata
        sigbuffer;
    end
    
    methods
        function obj=rt_vtl(parent,varargin)  %init
            obj@rt_visualizer(parent,varargin{:});  % superclass contructor
            obj.fullname='Vocal tract visualizer'; % full name identifies it later on the screen
            pre_init(obj);  % add the parameter gui
            
            s='Vocal tract visualizer adapted from code from Hideki Kawahara based on lpc analysis';
            s=[s, 'https://github.com/HidekiKawahara/SparkNG'];
            obj.descriptor=s;
            
        end
        
        function obj=post_init(obj)
                        post_init@rt_visualizer(obj);

%             figure(1);
            myGUIdata.samplingFrequency = 8000; % in Hz
            myGUIdata.windowLength = obj.parent.FrameLength/obj.parent.SampleRate; % in second
            myGUIdata.windowLengthInSamples = round(obj.parent.FrameLength);% *8000/obj.parent.Fs);
            myGUIdata.fftl = 256;
            
            w = blackman(myGUIdata.windowLengthInSamples);
            w = w/sqrt(sum(w.^2));
            myGUIdata.window = w;
% % %             subplot(2,2,3);
% % %             fs = myGUIdata.samplingFrequency;
% % %             myGUIdata.displayFrequencyAxis = (0:myGUIdata.fftl-1)/myGUIdata.fftl*fs;
% % %             tt = (1:myGUIdata.windowLengthInSamples)'/fs;
% % %             %x = randn(myGUIdata.windowLengthInSamples,1);
% % %             x = sin(2*pi*440*tt);
% % %             pw = 10*log10(abs(fft(x.*w,myGUIdata.fftl)).^2/myGUIdata.fftl);
% % %             plot(myGUIdata.displayFrequencyAxis,pw);
% % %             hold on;
% % %             plot(myGUIdata.displayFrequencyAxis,pw,'r','linewidth',2);grid on;
% % %             axis([0 fs/2 -110 0]);
% % %             set(gca,'fontsize',14,'linewidth',2);
% % %             xlabel('frequency (Hz)')
% % %             ylabel('level (dB rel. MSB)');
% % %             legend('power spectrum','14th order LPC');
            
%             subplot(2,2,2);
%             logAreaFunction = [4 3.7 4 2.7 2.2 1.9 1.9 1.5 0.8 0];
%             locationList = [1 3 5 7 9 11 13 15 17 19];
%             displayLocationList = 0:0.1:21;
%             displayLogArea = interp1(locationList,logAreaFunction,displayLocationList,'nearest','extrap');
%             plot(displayLocationList,displayLogArea-mean(displayLogArea),'linewidth',4);
%             hold on;
%             plot(displayLocationList,0*displayLogArea,'linewidth',1);
%             for ii = 0:20
%                 magCoeff = 1;
%                 if rem(ii,5) == 0
%                     magCoeff = 2;
%                     text(ii,-0.7,num2str(ii),'fontsize',16,'HorizontalAlignment','center');
%                 end
%                 if rem(ii,10) == 0
%                     magCoeff = 3;
%                 end
%                 plot([ii ii],[-0.1 0.1]*magCoeff);
%             end
%             axis([-0.5 20.5 -5 5]);
%             axis off
            
            
            vax=obj.viz_axes;

%             subplot(2,2,4);
            %             axes(handles.tract3DAxis);
            crossSection =  [0.2803; ...
                0.6663; ...
                0.5118; ...
                0.3167; ...
                0.1759; ...
                0.1534; ...
                0.1565; ...
                0.1519; ...
                0.0878; ...
                0.0737];
            [X,Y,Z] = cylinder(crossSection,40);
            myGUIdata.tract3D = surf(vax,Z,Y,X);
            view(vax,-26,12);
            axis(vax,[0 1 -1 1 -1 1]);
            vax.Visible='off';
%             axis('vis3d');
            rotate3d(vax,'on');
            
            myGUIdata.maxLevel = -100;

            
            obj.sigbuffer=circbuf1(round(obj.parent.SampleRate*obj.parent.PlotWidth)); %zeros(pa
            obj.myGUIdata=myGUIdata;
            
        end
        
        function plot(obj,sig)
            
            sig=resample(sig,8000,obj.parent.SampleRate);
            
            myGUIdata=obj.myGUIdata;
            %             handleForTimer = get(obj,'userData');
            %             myGUIdata = guidata(handleForTimer);
            w = myGUIdata.window;
            numberOfSamples = length(w);
            
            push(obj.sigbuffer,sig);
            tmp=get(obj.sigbuffer);
            tmpAudio=tmp(end-length(w):end);

            
            %                 tmpAudio = getaudiodata(myGUIdata.recordObj1);
            currentPoint = length(tmpAudio);
            x = tmpAudio(currentPoint-numberOfSamples+1:currentPoint);
            %x = [0;diff(x)];
            pw = abs(fft(x.*w,myGUIdata.fftl)).^2/myGUIdata.fftl;
            pwdB = 10*log10(pw);
           
            
% % %             subplot(2,2,3);
% % %             cla
% % %             hold on
% % %             plot(myGUIdata.displayFrequencyAxis,pwdB);
% % %             ac = real(ifft(pw));
% % %             [alp,err,k] = levinson(ac,14);
% % %             env = 1.0./abs(fft(alp,myGUIdata.fftl)).^2;
% % %             env = sum(pw)*env/sum(env);
% % %             envDB = 10*log10(env);
% % %             plot(myGUIdata.displayFrequencyAxis,envDB,'r','linewidth',2);
% % %              axis([0 8000/2 -110 0]);
% % %             set(gca,'fontsize',14,'linewidth',2);
% % %             xlabel('frequency (Hz)')
% % %             ylabel('level (dB rel. MSB)');
% % %             legend('power spectrum','14th order LPC');
% % %             grid on;
            
            
%             subplot(2,2,2);
%             cla
%             hold on
%             
%             % axes(handles.VTDisplayAxis);
%             logAreaFunction = [4 3.7 4 2.7 2.2 1.9 1.9 1.5 0.8 0];
%             locationList = [1 3 5 7 9 11 13 15 17 19];
%             displayLocationList = 0:0.1:21;
%             displayLogArea = interp1(locationList,logAreaFunction,displayLocationList,'nearest','extrap');
%             logAreaHandle = plot(displayLocationList,displayLogArea-mean(displayLogArea),'linewidth',4);
%             hold on;
%             plot(displayLocationList,0*displayLogArea,'linewidth',1);
%             for ii = 0:20
%                 magCoeff = 1;
%                 if rem(ii,5) == 0
%                     magCoeff = 2;
%                     text(ii,-0.7,num2str(ii),'fontsize',16,'HorizontalAlignment','center');
%                 end
%                 if rem(ii,10) == 0
%                     magCoeff = 3;
%                 end
%                 plot([ii ii],[-0.1 0.1]*magCoeff);
%             end
%             axis([-0.5 20.5 -5 5]);
%             axis off
%             title('log area function')
            
            logArea = signal2logArea(sig);
%             nSection = length(logArea);
%             locationList = (1:nSection)*2-1;
%             xdata = get(logAreaHandle,'xdata');
%             displayLogArea = interp1(locationList,logArea,xdata,'nearest','extrap');
%             set(logAreaHandle,'ydata',displayLogArea-mean(displayLogArea));
%             
%             subplot(2,2,4);
%             cla
%             hold on
            %        axes(handles.tract3DAxis);
            
            vax=obj.viz_axes;
            [X,Y,Z] = cylinder(tubeDisplay(logArea),40);
            tract3D = surf(Z,Y,X,'parent',vax);
%             view(vax,-26,12);
%             axis(vax,[0 1 -1 1 -1 1]);
%             axis off;
%             axis(vax,'vis3d');
%             rotate3d on;
            title(vax,'One dimensional tube model')
            
            
            
        end
        
        function obj=change_parameter(obj)
        end
    end
    
end
