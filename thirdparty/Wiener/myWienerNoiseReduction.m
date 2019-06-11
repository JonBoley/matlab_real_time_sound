function [esTSNR,esHRNR]=myWienerNoiseReduction(noisy_speech,fs,IS)
% adapted by SB for real time use

% [esTSNR,esHRNR]=WIENERNOISEREDUCTION(noisy_speech,fs,IS)
%
% Title  :      Wiener Noise Suppressor with TSNR & HRNR algorithms
%
% Description : Wiener filter based on tracking a priori SNR using Decision-Directed 
%               method, proposed by Plapous et al 2006. The two-step noise reduction
%               (TSNR) technique removes the annoying reverberation effect while
%               maintaining the benefits of the decision-directed approach. However,
%               classic short-time noise reduction techniques, including TSNR, introduce
%               harmonic distortion in the enhanced speech. To overcome this problem, a
%               method called harmonic regeneration noise reduction (HRNR)is implemented
%               in order to refine the a priori SNR used to compute a spectral gain able 
%               to preserve the speech harmonics.
%               
% 
% Reference :   Plapous, C.; Marro, C.; Scalart, P., "Improved Signal-to-Noise Ratio
%               Estimation for Speech Enhancement", IEEE Transactions on Audio, Speech,
%               and Language Processing, Vol. 14, Issue 6, pp. 2098 - 2108, Nov. 2006 
%
% Input Parameters :  
%   noisy_speech          Noisy speech 
%   fs          Sampling frequency (in Hz)
%   IS          Initial Silence (or non-speech activity) Period (in number of samples)
%
% Output Parameters : enhanced speech  
%   esTSNR      enhanced speech with the Two-Step Noise Reduction method 
%   esHNRN      enhanced speech with the Harmonic Regeneration Noise Reduction method
%             
%Author :       LIU Ming, 2008
%Modified :     SCALART Pascal october, 2008
%
%
% ------- input noisy speech  --------
l = length(noisy_speech);
% s=noisy_speech;
wl = fix(0.020*fs)    % window length is 20 ms

NFFT=2*wl             % FFT size is twice the window length



hanwin = hanning(wl);
    IS=10*wl;             %Initial Silence or Noise Only part in samples (= ten frames)

    %% -------- compute noise statistics ----------
nsum = zeros(NFFT,1);
count = 0; 
    for m = 0:IS-wl
     nwin = data(m+1:m+wl).*hanwin;	
      nsum = nsum + abs(fft(nwin,NFFT)).^2;
     count = count + 1;
    end
d= (nsum)/count;



%% --------- main algorithm ---------------
SP = 0.25;      % Shift percentage is 50 % Overlap-Add method works good with this value
normFactor=1/SP;
overlap = fix((1-SP)*wl); % overlap between sucessive frames
offset = wl - overlap;
max_m = fix((l-NFFT)/offset);
% zvector = zeros(NFFT,1);
oldmag = zeros(NFFT,1);
news = zeros(l,1);
phasea=zeros(NFFT,max_m);
xmaga=zeros(NFFT,max_m);
tsnra=zeros(NFFT,max_m);
newmags=zeros(NFFT,max_m);
alpha = 0.98;
%Iteration to remove noise
%% --------------- TSNR ---------------------
for m = 0:max_m
   begin = m*offset+1;    
   iend = m*offset+wl;
   speech = noisy_speech(begin:iend);       %extract speech segment
   winy = hanwin.*speech;   %perform hanning window
   ffty = fft(winy,NFFT);          %perform fast fourier transform
   phasey = angle(ffty);         %extract phase
   phasea(:,m+1)=phasey;       %for HRNR use
   magy = abs(ffty);             %extract magnitude
   xmaga(:,m+1)= magy;           %for HRNR use
   postsnr = ((magy.^2) ./ d)-1 ;      %calculate a posteriori SNR
   postsnr=max(postsnr,0.1);  % limitation to prevent distorsion
   
   %calculate a priori SNR using decision directed approach
   eta = alpha * ( (oldmag.^2)./d ) + (1-alpha) * postsnr;
   newmag = (eta./(eta+1)).*  magy;
   
   %calculate TSNR
   tsnr = (newmag.^2) ./ d;
   Gtsnr = tsnr ./ (tsnr+1);         %gain of TSNR 
   tsnra(:,m+1)=Gtsnr;    
   %Gtsnr=max(Gtsnr,0.1);  
   Gtsnr = gaincontrol(Gtsnr,NFFT/2);
   
      %for HRNR use
   newmag = Gtsnr .* magy;
   newmags(:,m+1) = newmag;     %for HRNR use
   ffty = newmag.*exp(i*phasey);
   oldmag = abs(newmag);
   news(begin:begin+NFFT-1) = news(begin:begin+NFFT-1) + real(ifft(ffty,NFFT))/normFactor;
end
esTSNR=news;
%% --------------- HRNR -----------------------
%non linearity
newharm= max(esTSNR,0);
news = zeros(l,1);
%
for m = 0:max_m
   begin = m*offset+1;    
   iend = m*offset+wl;
   nharm = hanwin.*newharm(begin:iend);
   ffth = abs(fft(nharm,NFFT));          %perform fast fourier transform
   snrham= ( (tsnra(:,m+1)).*(abs(newmags(:,m+1)).^2) + (1-(tsnra(:,m+1))) .* (ffth.^2) ) ./d;
   
   newgain= (snrham./(snrham+1));
   %newgain=max(newgain,0.1);  
   
   newgain=gaincontrol(newgain,NFFT/2);
   
   newmag = newgain .*  xmaga(:,m+1);
 
   ffty = newmag.*exp(i*phasea(:,m+1));
   
   news(begin:begin+NFFT-1) = news(begin:begin+NFFT-1) + real(ifft(ffty,NFFT))/normFactor;
end;


%Output
esHRNR=news;
figure;
[B,f,T] = specgram(noisy_speech,NFFT,fs,hanning(wl),wl-10);
imagesc(T,f,20*log10(abs(B)));axis xy;colorbar
title(['Spectrogram - noisy speech'])
xlabel('Time (sec)');ylabel('Frequency (Hz)');
figure;
[B,f,T] = specgram(esTSNR,NFFT,fs,hanning(wl),wl-10);
imagesc(T,f,20*log10(abs(B)));axis xy;colorbar
title(['Spectrogram - output speech TSNR'])
xlabel('Time (sec)');ylabel('Frequency (Hz)');
figure;
[B,f,T] = specgram(esHRNR,NFFT,fs,hanning(wl),wl-10);
imagesc(T,f,20*log10(abs(B)));axis xy;colorbar
title(['Spectrogram - output speech HRNR'])
xlabel('Time (sec)');ylabel('Frequency (Hz)');


