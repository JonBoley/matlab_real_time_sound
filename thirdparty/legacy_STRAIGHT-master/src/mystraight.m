% mystraight

clear all
close all

f0floor=40;
f0ceil=800;
fs=22050;	% sampling frequency (Hz)
framem=40;	% default frame length for pitch extraction (ms)
shiftm=1;       % default frame shift (ms) for spectrogram
f0shiftm=1;     % default frame shift (ms) for F0 information
fftl=2048;	% default FFT length
eta=1.4;        % time window stretch factor
pc=0.6;         % exponent for nonlinearity
mag=0.2;      % This parameter should be revised.
framel=framem*fs/1000;

if fftl < framel
    fftl=2^ceil(log(framel)/log(2));
end
fftl2=fftl/2;
defaultch=1; % 17/Feb./2001

%-------------- Decision parameter for source information
acth=0.5;	% Threshold for normalized correlation (dimension less)
pwth=32;	% Threshold for instantaneous power below maximum (dB)

delsp=0.5; 	%  standard deviation of random group delay in ms 26/June/2002
gdbw=70; 	% smoothing window length of random group delay (in Hz)
cornf=4000;  	% corner frequency for random phase (Hz) 26/June 2002
delfrac=0.2;  % This parameter should be revised.
delfracind=0;
fname='vaiueo2d.wav';		% input data file name
hr='on';
cpath=pwd;
upsampleon=0;
defaultendian=2; % on mac
indefaultendian=defaultendian;
outdefaultendian=defaultendian;

%% read
[x,fs]=audioread(fname);
x=x*32768;

x=[x;zeros(18000-length(x),1)];

steps=1024;
s1=1;
s2=s1+steps;
totsy=[];

for iii=1:14
    xold=x(s1:s2);
    s1=s2+1;
    s2=s1+steps;
    iii
    
    %% analyse source
    nvo=24;
    nvc=ceil(log(f0ceil/f0floor)/log(2)*nvo);
    grafix=0;
    [f0v,vrv,dfv,~,aav]=fixpF0VexMltpBG4(xold,fs,f0floor,nvc,nvo,1.2,grafix,shiftm,1,5,0.5,1);

    [pwt,pwh]=plotcpower(xold,fs,shiftm,grafix);
    
    [f0raw,irms,~,amp]=f0track5(f0v,vrv,dfv,pwt,pwh,aav,shiftm,grafix);
    avf0=mean(f0raw(f0raw>0));
    
    
    dn=floor(fs/(f0ceil*3*2)); 
    [f0raw,ecr]=refineF06(decimate(xold,dn),fs/dn,f0raw,1024,1.1,3,f0shiftm,1,length(f0raw),grafix); % 31/Aug./2004
    f0t=f0raw;
    
    f0t(f0t==0)=f0t(f0t==0)*NaN;tt=1:length(f0t);
    
    %---------- This part is for maintaining compatibility with old synthesis routine ----
    f0var=max(0.00001,irms).^2;
    f0var(f0var>0.99)=f0var(f0var>0.99)*0+100;
    f0var(f0raw==0)=f0var(f0raw==0)*0+100;
    f0varbak = f0var;  % backup for f0var (18/July/1999)
    f0var=f0var/2;  %  2 is a magic number. If everything is OK, it should be 1.
    f0var=(f0var>0.9);  % This modification is to make V/UV decision crisp  (18/July/1999)
    f0varL=f0var;
    
    f0raw(f0raw<=0)=f0raw(f0raw<=0)*0; % safeguard 31/August/2004
    f0raw(f0raw>f0ceil)=f0raw(f0raw>f0ceil)*0+f0ceil; % safeguard 31/August/2004
    
    
    %% analyze 1CHX
    [n2sgrambk,~]=straightBodyC03ma(xold,fs,shiftm,fftl,f0raw,f0var,f0varL,eta,pc,grafix); %%
    n3sgram=specreshape(fs,n2sgrambk,eta,pc,mag,f0raw,grafix);
    
    
    %% synthesize
    pcnv=1.5; 	% pitch stretch
    fconv=1.0; 	% frequency stretch
    sconv=1; 	% time stretch
    
    sy=straightSynthTB06(n3sgram,f0raw,f0var,f0varL,shiftm,fs, ...
        pcnv,fconv,sconv,gdbw,delfrac,delsp,cornf,delfracind);
    dBsy=powerchk(sy,fs,15);
    cf=(20*log10(32768)-22)-dBsy;
    sy=sy*(10.0.^(cf/20));
    sy(isnan(sy))=0;
  
    totsy=[totsy;sy];
end

%% play
straightsound(totsy,fs);


