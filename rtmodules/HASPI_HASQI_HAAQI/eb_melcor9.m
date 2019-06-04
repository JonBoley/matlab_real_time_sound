function [CMave,CMlow,CMhigh,CMmod] = eb_melcor9(x,y,thr,addnoise,segsize)
% Function to compute the cross-correlations between the input signal
% time-frequency envelope and the distortion time-frequency envelope. For
% each time interval, the log spectrum is fitted with a set of half-cosine
% basis functions. The spectrum weighted by the basis functions corresponds
% to mel cepstral coefficients computed in the frequency domain. The 
% amplitude-normalized cross-covariance between the time-varying basis
% functions for the input and output signals is then computed for each of
% the 8 modulation frequencies.
%
% Calling variables:
% x		    subsampled input signal envelope in dB SL in each critical band
% y		    subsampled distorted output signal envelope
% thr	    threshold in dB SPL to include segment in calculation
% addnoise  additive Gaussian noise to ensure 0 cross-corr at low levels
% segsize   segment size in ms used for the envelope LP filter (8 msec)
%
% Output:
% CMave     average of the modulation correlations across analysis frequency
%           bands and modulation frequency bands, basis functions 2 -6
% CMlow     average over the four lower mod freq bands, 0 - 20 Hz
% CMhigh    average over the four higher mod freq bands, 20 - 125 Hz
% CMmod     vector of cross-correlations by modulation frequency,
%           averaged over ananlysis frequency band
%
% James M. Kates, 24 October 2006.
% Difference signal removed for cochlear model, 31 January 2007.
% Absolute value added 13 May 2011.
% Changed to loudness criterion for silence threshold, 28 August 2012.
% Version using envelope modulation filters, 15 July 2014.
% Modulation frequency vector output added 27 August 2014.

% Processing parameters
nbands=size(x,1);
small=1.0e-30;

% Mel cepstrum basis functions (mel cepstrum because of auditory bands)
nbasis=6; %Number of cepstral coefficients to be used
freq=0:nbasis-1;
k=0:nbands-1;
cepm=zeros(nbands,nbasis);
for nb=1:nbasis
	basis=cos(freq(nb)*pi*k/(nbands-1));
	cepm(:,nb)=basis/norm(basis);
end

% Find the segments that lie sufficiently above the quiescent rate
xLinear=10.^(x/20); %Convert envelope dB to linear (specific loudness)
xsum=sum(xLinear,1)/nbands; %Proportional to loudness in sones
xsum=20*log10(xsum); %Convert back to dB (loudness in phons)
index=find(xsum > thr); %Identify those segments above threshold
nsamp=length(index); %Number of segments above threshold

% Exit if not enough segments above zero
if nsamp <= 1
	m1=0;
	xy=zeros(nbasis,1);
	fprintf('Function eb_melcor9: Signal below threshold, outputs set to 0.\n');
	return;
end

% Remove the silent intervals
x=x(:,index);
y=y(:,index);

% Add the low-level noise to the envelopes
x=x + addnoise*randn(size(x));
y=y + addnoise*randn(size(y));

% ---------------------------------------
% Compute the mel cepstrum coefficients using only those segments
% above threshold
xcep=zeros(nbasis,nsamp); %Input
ycep=zeros(nbasis,nsamp); %Output
for n=1:nsamp
	for k=1:nbasis
		xcep(k,n)=sum(x(:,n).*cepm(:,k));
		ycep(k,n)=sum(y(:,n).*cepm(:,k));
	end
end

% Remove the average value from the cepstral coefficients. The
% cross-correlation thus becomes a cross-covariance, and there
% is no effect of the absolute signal level in dB.
for k=1:nbasis
	xcep(k,:)=xcep(k,:) - mean(xcep(k,:));
	ycep(k,:)=ycep(k,:) - mean(ycep(k,:));
end

% ---------------------------------------
% Envelope sampling parameters
fsub=1000.0/(0.5*segsize); %Envelope sampling frequency in Hz
fnyq=0.5*fsub; %Envelope Nyquist frequency

% Modulation filter bands, segment size is 8 msec
edge=[4, 8, 12.5, 20, 32, 50, 80]; %8 bands covering 0 to 125 Hz
nmod=1 + length(edge); %Number of modulation filter bands

% Design the linear-phase envelope modulation filters
nfir=round(128*(fnyq/125)); %Adjust filter length to sampling rate
nfir=2*floor(nfir/2); %Force an even filter length
nfir2=nfir/2;
b=cell(nmod,1);
b{1}=fir1(nfir,edge(1)/fnyq,hann(nfir+1)); %LP filter 0-4 Hz
b{nmod}=fir1(nfir,edge(nmod-1)/fnyq,'high',hann(nfir+1)); %HP 80-125 Hz
for m=2:nmod-1
    b{m}=fir1(nfir,[edge(m-1) edge(m)]/fnyq,hann(nfir+1)); %Bandpass filter
end

% Convolve the input and output envelopes with the modulation filters
X=cell(nmod,nbasis);
Y=X;
for m=1:nmod
    for j=1:nbasis
        c=conv(b{m},xcep(j,:));
        X{m,j}=c((nfir2+1):(nfir2+nsamp)); %Remove the transients
        c=conv(b{m},ycep(j,:));
        Y{m,j}=c((nfir2+1):(nfir2+nsamp)); %Remove the transients
    end
end

% Compute the cross-covariance matrix
CM=zeros(nmod,nbasis);
for m=1:nmod
    for j=1:nbasis
%       Index j gives the input reference band
        xj=X{m,j}; %Input freq band j, modulation freq m
        xj=xj - mean(xj);
        xsum=sum(xj.^2);
%       Processed signal band 
        yj=Y{m,j}; %Input freq band j, modulation freq m
        yj=yj - mean(yj);
        ysum=sum(yj.^2);
%       Cross-correlate the reference and processed signals
        if (xsum < small) || (ysum < small)
            CM(m,j)=0;
        else
            CM(m,j)=abs(sum(xj.*yj))/sqrt(xsum*ysum);
        end
    end
end

% Average over the  modulation filters and basis functions 2 - 6
CMave=0;
for m=1:nmod
    for j=2:nbasis
        CMave=CMave + CM(m,j);
    end
end
CMave=CMave/(nmod*(nbasis-1));

% Average over the four lower modulation filters
CMlow=0;
for m=1:4
    for j=2:nbasis
        CMlow=CMlow + CM(m,j);
    end
end
CMlow=CMlow/(4*(nbasis-1));

% Average over the four upper modulation filters
CMhigh=0;
for m=5:8
    for j=2:nbasis
        CMhigh=CMhigh + CM(m,j);
    end
end
CMhigh=CMhigh/(4*(nbasis-1));

% Average each modulation frequency over the basis functions
CMmod=zeros(nmod,1);
for m=1:nmod
    ave=0;
    for j=2:nbasis
        ave=ave + CM(m,j);
    end
    CMmod(m)=ave/(nbasis-1);
end
end
