
classdef rt_hlsimulation < rt_manipulator
    properties
        msWname
        msMaxScale
        msEntropy
        HLM
        myfilter
    end
    
    methods
        
        function obj=rt_hlsimulation(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Hearing Loss simulation';
            pre_init(obj);  % add the p if nargin<2
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            listhl={'normal';'average 50';'average 60';'average 70';'average 80'};
            hlmethods={'wavelet';'filter'};
            addParameter(pars,'Method','wavelet');
            addParameter(pars,'HLSeverity','average 50');
            
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            add(obj.p,param_popupmenu('Method',pars.Results.Method,'list',hlmethods));
            add(obj.p,param_popupmenu('HLSeverity',pars.Results.HLSeverity,'list',listhl));
            
            obj.descriptor='wavelet based simulation of hearing loss. For info see here:';
            
        end
        
        function obj=post_init(obj) % called the second times around
            meth=getvalue(obj.p,'Method');
            switch meth
                case 'filter'  % simple filter
                    obj.myfilter=rt_graficequal(obj.parent);
                    
                    %TODO
                    
                case 'wavelet'
                    
                    mod=getvalue(obj.p,'HLSeverity');
                    hlmodel=[mod,'.txt'];
                    if ~isfile(['./rtmodules/HLmodel/',hlmodel])
                        fprintf('file %s doesn''t exist',hlmodel)
                        return
                    end
                    data=load(hlmodel);
                    
                    
                    Bark(1,1)=0; Bark(1,2)=50; Bark(1,3)=100;
                    Bark(2,1)=100; Bark(2,2)=150; Bark(2,3)=200;
                    Bark(3,1)=200; Bark(3,2)=250; Bark(3,3)=300;
                    Bark(4,1)=300; Bark(4,2)=350; Bark(4,3)=400;
                    Bark(5,1)=400; Bark(5,2)=450; Bark(5,3)=510;
                    Bark(6,1)=510; Bark(6,2)=570; Bark(6,3)=630;
                    Bark(7,1)=630; Bark(7,2)=700; Bark(7,3)=770;
                    Bark(8,1)=770; Bark(8,2)=840; Bark(8,3)=920;
                    Bark(9,1)=920; Bark(9,2)=1000; Bark(9,3)=1080;
                    Bark(10,1)=1080; Bark(10,2)=1170; Bark(10,3)=1270;
                    Bark(11,1)=1270; Bark(11,2)=1370; Bark(11,3)=1480;
                    Bark(12,1)=1480; Bark(12,2)=1600; Bark(12,3)=1720;
                    Bark(13,1)=1720; Bark(13,2)=1850; Bark(13,3)=2000;
                    Bark(14,1)=2000; Bark(14,2)=2150; Bark(14,3)=2320;
                    Bark(15,1)=2320; Bark(15,2)=2500; Bark(15,3)=2700;
                    Bark(16,1)=2700; Bark(16,2)=2900; Bark(16,3)=3150;
                    Bark(17,1)=3150; Bark(17,2)=3400; Bark(17,3)=3700;
                    Bark(18,1)=3700; Bark(18,2)=4000; Bark(18,3)=4400;
                    Bark(19,1)=4400; Bark(19,2)=4800; Bark(19,3)=5300;
                    Bark(20,1)=5300; Bark(20,2)=5800; Bark(20,3)=6400;
                    Bark(21,1)=6400; Bark(21,2)=7000; Bark(21,3)=7700;
                    
                    %centre frequency measure adaptive
                    WPTCf(1)=66;
                    WPTCf(2)=175;
                    WPTCf(3)=322;
                    WPTCf(4)=408;
                    WPTCf(5)=583;
                    WPTCf(6)=678;
                    WPTCf(7)=832;
                    WPTCf(8)=898;
                    WPTCf(9)=1166;
                    WPTCf(10)=1355;
                    WPTCf(11)=1645;
                    WPTCf(12)=1816;
                    WPTCf(13)=2185;
                    WPTCf(14)=2355;%not good
                    WPTCf(15)=2710;
                    WPTCf(16)=3310;
                    WPTCf(17)=3610;
                    WPTCf(18)=4660;
                    WPTCf(19)=5420;
                    WPTCf(20)=6580;
                    WPTCf(21)=7501;
                    
                    WPTCh(1)=1;
                    WPTCh(2)=1;
                    WPTCh(3)=1;
                    WPTCh(4)=1;
                    WPTCh(5)=1;
                    WPTCh(6)=1;
                    WPTCh(7)=1;
                    WPTCh(8)=1;
                    WPTCh(9)=2;
                    WPTCh(10)=2;
                    WPTCh(11)=2;
                    WPTCh(12)=2;
                    WPTCh(13)=2;
                    WPTCh(14)=2;
                    WPTCh(15)=4;
                    WPTCh(16)=4;
                    WPTCh(17)=4;
                    WPTCh(18)=8;
                    WPTCh(19)=8;
                    WPTCh(20)=8;
                    WPTCh(21)=8;
                    %WPTCh(22)=16;
                    %WPTCh(23)=16;
                    %WPTCh(24)=32;
                    
                    fs=16000;
                    msInt=fs/2/2^6;
                    tmpi=0;
                    msCons=82.9/125;
                    for i=1:21
                        WPTf(i,1)=tmpi*msInt;
                        WPTf(i,3)=(tmpi+WPTCh(i))*msInt;
                        h=WPTf(i,3)-WPTf(i,1);
                        WPTf(i,2)=WPTf(i,1)+h*msCons;
                        WPTf(i,1)=WPTf(i,2)-h/2/msCons;
                        WPTf(i,3)=WPTf(i,2)+h/2/msCons;
                        
                        if WPTf(i,1)<0
                            WPTf(i,1)=0;
                        end
                        if WPTf(i,3)>fs/2
                            WPTf(i,3)=fs/2;
                        end
                        
                        tmpi=tmpi+WPTCh(i);
                    end
                    
                    x=Bark(:,2);y=WPTf(:,2);
                    s=[1:0.0001:2];
                    for i=1:length(s)
                        z(i)=mean(abs((y/s(i)-x)./x));
                    end
                    
                    
                    tmpstr='';
                    for i=1:21
                        ts1=sprintf('Ch%d (%d~%dHz)',i,round(WPTf(i,1)),round(WPTf(i,3)));
                        handles.FileInfo.chnname(i).name=ts1;
                        tmpstr=strcat(tmpstr,ts1);
                        if i<21
                            tmpstr=strcat(tmpstr,'|');
                        end
                    end
                    
                    handles.AnaData.selno=0;
                    handles.AnaData.Bark=Bark;
                    handles.AnaData.WPTCh=WPTCh;
                    handles.AnaData.WPTCf=WPTCf;
                    handles.AnaData.WPTf=WPTf;
                    
                    
                    
                    for i=1:length(data)
                        handles.rawlistone=round(data(i,1));
                        handles.msHTh=num2str(data(i,3));
                        handles.msTMt0=num2str(data(i,4));
                        handles.msTMt0D=num2str(data(i,5));
                        handles.msTMp=num2str(data(i,6));
                        handles.msFMKfd=num2str(data(i,7));
                        handles.msFMKfu=num2str(data(i,8));
                        
                        handles.AnaData.selno=handles.AnaData.selno+1;
                        
                        handles.AnaData.selfirstchn(handles.AnaData.selno)=handles.AnaData.selno;
                        tmp_str=handles.FileInfo.chnname(handles.rawlistone);
                        tmp_str.name=strcat(tmp_str.name,'  (HT:');
                        tmp_str.name=strcat(tmp_str.name,handles.msHTh);
                        tmp_str.name=strcat(tmp_str.name,', TM t0:');
                        tmp_str.name=strcat(tmp_str.name,handles.msTMt0);
                        tmp_str.name=strcat(tmp_str.name,', TM t0D:');
                        tmp_str.name=strcat(tmp_str.name,handles.msTMt0D);
                        tmp_str.name=strcat(tmp_str.name,', TM power:');
                        tmp_str.name=strcat(tmp_str.name,handles.msTMp);
                        tmp_str.name=strcat(tmp_str.name,', TF down:');
                        tmp_str.name=strcat(tmp_str.name,handles.msFMKfd);
                        tmp_str.name=strcat(tmp_str.name,', TF up:');
                        tmp_str.name=strcat(tmp_str.name,handles.msFMKfu);
                        tmp_str.name=strcat(tmp_str.name,')');
                        
                        handles.AnaData.selfirstchnname(handles.AnaData.selno)=tmp_str;
                        tmp_str=getliststr(handles.AnaData.selno,handles.AnaData.selfirstchnname);
                        %     set(handles.sellist,'String',tmp_str,'Value',1);
                        handles.sellist=tmp_str;
                        handles.AnaData.HTL(handles.AnaData.selno)=str2num(handles.msHTh);
                        handles.AnaData.TMt0(handles.AnaData.selno)=str2num(handles.msTMt0);
                        handles.AnaData.TMt0D(handles.AnaData.selno)=str2num(handles.msTMt0D);
                        handles.AnaData.TMp(handles.AnaData.selno)=str2num(handles.msTMp);
                        handles.AnaData.FMKfd(handles.AnaData.selno)=str2num(handles.msFMKfd);
                        handles.AnaData.FMKfu(handles.AnaData.selno)=str2num(handles.msFMKfu);
                    end
                    
                    
                    
                    fs=obj.parent.SampleRate;
                    
                    handles.RawData.chnno=21;
                    % generating recruitment hearing loss model - begin
                    handles.RawData.msCalSPL=65;%sound pressure level is set as 65 dB.
                    obj.msWname = 'dmey';
                    obj.msMaxScale=6; %the level is fixed as 6 for resampling at 14kHz.
                    obj.msEntropy='shannon';
                    
                    HLM.WPTCh=handles.AnaData.WPTCh;
                    HLM.Bark=handles.AnaData.Bark;
                    HLM.Wname=obj.msWname;
                    HLM.MaxScale=obj.msMaxScale;
                    HLM.Calfs=fs;
                    HLM.Calrms=std(y);
                    HLM.fs=fs;
                    HLM.CalSPL=handles.RawData.msCalSPL;%sound pressure level is set as 65 dB.
                    AnaData=handles.AnaData;
                    for i=1:AnaData.selno
                        SPLTh=AnaData.HTL(i);
                        Kfd=AnaData.FMKfd(i);
                        Kfu=AnaData.FMKfu(i);
                        Kt0=AnaData.TMt0(i);
                        Kt0D=AnaData.TMt0D(i);
                        Ktp=AnaData.TMp(i);
                        Cn=AnaData.selfirstchn(i);
                        Cf0=HLM.Bark(Cn,2);
                        tmpHLM=msGenSpikeCodingModel(HLM,SPLTh,Kfd,Kfu,Kt0,Kt0D,Ktp,Cn,Cf0);
                        RecHLM(i)=tmpHLM;
                    end
                    HLM.RecHLM=RecHLM;
                    obj.HLM=HLM;
                    
            end
            
        end
        
        function hlsim=apply(obj,sig)
            
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            
            meth=getvalue(obj.p,'Method');

            switch meth
                case 'filter'  % simple filter
                    hlsim=obj.myfilter(sig);
                    
                case 'wavelet'
                    
                    msAnaTree=msGetWPTCoeff(sig,obj.msMaxScale,obj.msEntropy,obj.msWname,obj.HLM.WPTCh);
                    % hearing loss model
                    msMaskedTree=msWPTTHMasking(msAnaTree,obj.HLM);
                    % wavelet recomposition
                    hlsim=wprec(msMaskedTree);
            end
        end
        
        function close(obj)
            if ~isempty(obj.myfilter)
                close(obj.myfilter);
            end
        end
    end
end
