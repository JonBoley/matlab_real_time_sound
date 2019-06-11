function res = fastAnnoyance(x,Fs,print)
    % reports Zwicker's Psychoacoustic Annoyance metric - a combination of
    % Loudness, Sharpness, Roughness and Fluctuation Strength. 
    % 
    % 
    % Input signals have samples in Pascals. 
    % 
    % Argument list 
    % x - Input signal in Pascals 
    % Fs - Sample rate
    % print - bool - true to print answers to screen
    % 
    
    if ~(Fs == 44100 || Fs == 40960 || Fs == 48000)
        error(['Incorrect sample rate for this roughness algorithm. Please ' ...
               're-sample original file to be Fs=44100,40960 or 48000 ' ...
               'Hz']);
    end
    
    % ****** Loudness and Sharpness *******
    length_sec = length(x)/Fs;
    % one external function call
    loudRes = Loudness_TimeVaryingSound_Zwicker(x,Fs,'mic','free',5,0.03,false);
    L = loudRes.Lx;
    S = loudRes.Sx;
    
    % ******* Fluctuation Strength ********
    % get ISLs into Nx24, not Nx240 for Bark Band filtering
    ISL = loudRes.InstantaneousSpecificLoudness;
    Fs_loudness = 500; % defined in software - block size in STFT
    ISLb = zeros(size(ISL,1),24);
    for k = 1:10
        ISLb = ISLb + ISL(:,k:10:240); % Instantaneous Specific Loudness (1 bark bands)
    end
    % smooth it out 
    ISLbs = zeros(size(ISLb));
    for j = 1:24
        % Instantaneous Specific Loudness, bark band, smoothed. 
        % use move average filter with 10Hz response time.
        ISLbs(:,j) = smooth(ISLb(:,j),0.1*Fs_loudness);
    end
    % ignore the start and end 1/8th second (which is not smoothed so well)
    cut = floor(0.125*Fs_loudness):length(ISL)-floor(0.125*Fs_loudness);
    ISLbs_cut = ISLbs(cut,:);
    % get peaks and troughs of the cuts, per band
    LDb = zeros(1,24);
    for bark = 1:24
        currentSig = ISLbs_cut(:,bark);
        % expect about four peaks per second,
        % get maximum peaks first
        % expect spacing greater than 1/10th second 
        [pk,pkloc] = findpeaks(currentSig,'NPeaks',floor(4*length_sec),'SortStr','descend','MinPeakDistance',0.1*Fs_loudness);
        [dip,diploc] = findpeaks(max(currentSig)-currentSig,'NPeaks',floor(4*length_sec),'SortStr','descend','MinPeakDistance',0.1*Fs_loudness);
        %%plot(t_ISL_cut,currentSig)
        %%hold on
        %%plot(t_ISL_cut(pkloc),pk,'kx')
        %%plot(t_ISL_cut(diploc),max(currentSig)-dip,'rx')
        % for each peak, get the level difference to the closest trough
        % to the left, and the closest to the right
        % not guaranteed to have the same number of peaks and troughs.
        if isempty(pk) % if no peaks in this band
            LDb(bark) = 0; % 
        else
            LD = zeros(length(pk),1);
            for pkidx = 1:length(pk) % for each peak 
                % find the closest dip in each direction
                currentPeakLocation = pkloc(pkidx);
                currentPeakHeight = pk(pkidx);
                % dips to the right and left of current
                right = currentPeakLocation < diploc;
                left = currentPeakLocation > diploc;
                diploc_right = diploc(right);
                diploc_left = diploc(left);
                dip_right = dip(right);
                dip_left = dip(left);
                [~,positionIndiplocright] = min(abs(currentPeakLocation-diploc_right));
                [~,positionIndiplocleft] = min(abs(currentPeakLocation-diploc_left));
                %get level differences
                Ld_left = currentPeakHeight - (max(currentSig)-dip_left(positionIndiplocleft));
                Ld_right = currentPeakHeight - (max(currentSig)-dip_right(positionIndiplocright));
                % shout
%                 if options.print
%                     fprintf('Bark Index %d, Peak index %d \n %d to the right & %d to the left.\n Closest dip right = %d away. Closest dip left = %d away\n Level differences %.3f left and %.3f right\n',...
%                     bark,pkidx,length(diploc_right),length(diploc_left),distanceToClosestRight,distanceToClosestLeft,Ld_left, Ld_right)
%                 end
                if ~(isempty(Ld_left) && isempty(Ld_right)) % if anything found
                    LD(pkidx) = max([Ld_left,Ld_right]);
                else
                    LD(pkidx) = 0; % no level difference here
                end

            end  
            LDb(bark) = mean(LD);
            % extract a scalar quantity from the array of Level Differences here. 
            % use mean of bark band level differences for the time being.
        end
    end
    F = sum(LDb)/40; % calibration factor to match
    % correct for SPL 
    SPLDiff= SPL(x) - 60;
    F = F * 2.^-(SPLDiff/20);
    F = F-0.4; %correct offset
    F = max(0,F); % limiting
    
    % ******** Roughness ********
    % format data correctly and create frames;
    
    x=x(:)*5; % fix signal orientation and scale by 5 for calibration
    overlapRatio = 2/3;
    N = 8192; % samples in block
    blockStartInterval = ceil(N * (1-overlapRatio));
    nWindows = (floor((length(x) - N) / blockStartInterval))+1;
    shift = ones(N,1)*((0:nWindows-1)*blockStartInterval);
    idx = (1:N)'*ones(1,nWindows);
    extract = shift + idx;
    frames = x(extract);
    wn = blackman(N) * ones(1,nWindows);
    frames = wn.*frames; % 
    
    %%%%%%%%%%%%%%%%%
    % BEGIN InitAll %
    %%%%%%%%%%%%%%%%%
    Bark = [0     0	   50	 0.5
            1   100	  150	 1.5
            2   200	  250	 2.5
            3   300	  350	 3.5
            4   400	  450	 4.5
            5   510	  570	 5.5
            6   630	  700	 6.5
            7   770	  840	 7.5
            8   920	 1000	 8.5
            9  1080	 1170	 9.5
            10  1270 1370	10.5
            11  1480 1600	11.5
            12  1720 1850	12.5
            13  2000 2150	13.5
            14  2320 2500	14.5
            15  2700 2900	15.5
            16  3150 3400	16.5
            17  3700 4000	17.5
            18  4400 4800	18.5
            19  5300 5800	19.5
            20  6400 7000	20.5
            21  7700 8500	21.5
            22  9500 10500	22.5
            23 12000 13500	23.5
            24 15500 20000	24.5];

    Bark2	= [sort([Bark(:,2);Bark(:,3)]),sort([Bark(:,1);Bark(:,4)])];
    N0	= round(20*N/Fs)+1; % low frequency index @ 20 Hz
    N01	= N0-1;
   % N50     = round(50*N/Fs)-N0+1;
    N2	= N/2+1;
    Ntop	= round(20000*N/Fs)+1; % high frequency index @ 20 kHz?
   % Ntop2	= Ntop-N0+1;
    dFs	= Fs/N;

    % Make list with Barknumber of each frequency bin
    Barkno	  = zeros(1,N2);
    f	  = N0:1:Ntop;
    Barkno(f) = interp1(Bark2(:,1),Bark2(:,2),(f-1)*dFs);

    % Make list of frequency bins closest to Cf's
    Cf = ones(2,24);
    for a=1:1:24
      Cf(1,a)=round(Bark((a+1),2)*N/Fs)+1-N0;
      Cf(2,a)=Bark(a+1,2);
    end
    %Make list of frequency bins closest to Critical Band Border frequencies
    Bf = ones(2,24);
    Bf(1,1)=round(Bark(1,3)*N/Fs);
    for a=1:1:24
      Bf(1,a+1)=round(Bark((a+1),3)*N/Fs)+1-N0;
      Bf(2,a)=Bf(1,a)-1;
    end
    Bf(2,25)=round(Bark((25),3)*N/Fs)+1-N0;

    %Make list of minimum excitation (Hearing Treshold)
    HTres= [	    0		  130
                    0.01      70
                    0.17      60
                    0.8	      30
                    1	      25
                    1.5	      20
                    2	      15
                    3.3	      10
                    4		  8.1
                    5		  6.3
                    6		  5
                    8		  3.5
                    10		  2.5
                    12		  1.7
                    13.3	  0
                    15		 -2.5
                    16		 -4
                    17		 -3.7
                    18		 -1.5
                    19		  1.4
                    20		  3.8
                    21		  5
                    22		  7.5
                    23 	      15
                    24 	      48
                    24.5 	  60
                    25		  130];

    k = (N0:1:Ntop);
    MinExcdB = interp1(HTres(:,1),HTres(:,2),Barkno(k));

    % Initialize constants and variables
    %zi    = 0.5:0.5:23.5;
    zb    = sort([Bf(1,:),Cf(1,:)]);
    MinBf = MinExcdB(zb);
    ei    = zeros(47,N);
    Fei   = zeros(47,N);

    % BarkNo  0     1   2   3   4   5   6   7   8     9     10
    %	 11     12  13  14  15  16  17  18  19  20  21  22  23  24 
    gr = [ 0,1,2.5,4.9,6.5,8,9,10,11,11.5,13,17.5,21,24;
           0,0.35,0.7,0.7,1.1,1.25,1.26,1.18,1.08,1,0.66,0.46,0.38,0.3];
    gzi    = zeros(1,47);
    h0     = zeros(1,47);
    k      = 1:1:47;
    gzi(k) = sqrt(interp1(gr(1,:)',gr(2,:)',k/2));

    % calculate a0
    a0tab =	[ 0	 0
              10	 0
              12	 1.15
              13	 2.31
              14	 3.85
              15	 5.62
              16	 6.92
              16.5	 7.38
              17	 6.92
              18	 4.23
              18.5	 2.31
              19	 0
              20	-1.43
              21	-2.59
              21.5	-3.57
              22	-5.19
              22.5	-7.41
              23	-11.3
              23.5	-20
              24	-40
              25	-130
              26	-999];

    a0    = ones(1,N);
    k     = (N0:1:Ntop);
    a0(k) = 10 .^ (0.05*(interp1(a0tab(:,1),a0tab(:,2),Barkno(k))));%db2amp;
            
    %%%%%%%%%%%%%%%
    % END InitAll %
    %%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%
    % BEGIN Hweights %
    %%%%%%%%%%%%%%%%%%
    % weights for freq. bins < N/2

    DCbins	= 2;

    H2 = [	0	0
            17  0.8
            23	0.95
            25	0.975
            32	1
            37	0.975
            48	0.9
            67  0.8
            90	0.7
            114 0.6
            171 0.4
            206	0.3
            247 0.2
            294	0.1
            358	0 ];

    H5 = [	0	0
            32  0.8
            43	0.95
            56	1
            69	0.975
            92	0.9
            120 0.8
            142	0.7
            165 0.6
            231 0.4
            277	0.3
            331 0.2
            397	0.1
            502	0 ];

    H16 = [	0       0
            23.5	0.4
            34      0.6
            47      0.8
            56      0.9
            63      0.95
            79  	1
            100     0.975
            115     0.95
            135     0.9
            159     0.85
            172     0.8
            194     0.7
            215     0.6
            244     0.5
            290     0.4
            348     0.3
            415     0.2
            500     0.1
            645     0	];

    H21 = [	0       0
            19      0.4
            44      0.8
            52.5	0.9
            58      0.95
            75      1
            101.5	0.95
            114.5	0.9
            132.5	0.85
            143.5	0.8
            165.5	0.7
            197.5	0.6
            241     0.5
            290     0.4
            348     0.3
            415     0.2
            500     0.1
            645 	0	];


    H42 = [ 0	0
            15	0.4
            41	0.8
            49	0.9
            53	0.965
            64	0.99
            71	1
            88	0.95
            94	0.9
            106	0.85
            115	0.8
            137	0.7
            180	0.6
            238	0.5
            290	0.4
            348	0.3
            415	0.2
            500	0.1
            645	0	];

    Hweight	= zeros(47,N);

    % weighting function H2
    last	= floor((358/Fs)*N) ;
    k	= DCbins+1:1:last;
    f	= (k-1)*Fs/N;
    Hweight(2,k) = interp1(H2(:,1),H2(:,2),f(k-DCbins));

    % weighting function H5
    last	=	floor((502/Fs)*N);
    k	=	DCbins+1:1:last;
    f	=	(k-1)*Fs/N;
    Hweight(5,k)	= interp1(H5(:,1),H5(:,2),f(k-DCbins));

    % weighting function H16
    last	=	floor((645/Fs)*N);
    k	=	DCbins+1:1:last;
    f	=	(k-1)*Fs/N;
    Hweight(16,k)	= interp1(H16(:,1),H16(:,2),f(k-DCbins));

    % weighting function H21
    Hweight(21,k)	= interp1(H21(:,1),H21(:,2),f(k-DCbins));

    % weighting function H42
    Hweight(42,k)	= interp1(H42(:,1),H42(:,2),f(k-DCbins));

    % H1-H4
    Hweight(1,:) = Hweight(2,:);
    Hweight(3,:) = Hweight(2,:);
    Hweight(4,:) = Hweight(2,:);

    % H5-H15
    for l =	6:1:15
      Hweight(l,:) = Hweight(5,:);
    end

    % H17-H20
    for l =	17:1:20
      Hweight(l,:) = Hweight(16,:);
    end

    % H22-H41
    for l =	22:1:41
      Hweight(l,:) = Hweight(21,:);
    end

    % H43-H47
    for l =	43:1:47
      Hweight(l,:) = Hweight(42,:);
    end

    %%%%%%%%%%%%%%%%
    % END Hweights %
    %%%%%%%%%%%%%%%%

    leveldB = 75; % Was 80 - I adjusted to give roughness = 1 for supplied signal;
    AmpCal = 10 .^ (0.05*leveldB)*2/(N*mean(blackman(N, 'periodic'))); 
    % Calibration between wav-level and loudness-level (assuming
    % blackman window and FFT will follow)

    Chno	=	47; % number of channels 
    Cal	 	=	0.25; % calibration factor - this is only applied to the Roughnesses. designed to compensate for signal level...
    %q		=	1:1:N; %indices up to signal length
    qb		=	N0:1:Ntop; 
    freqs	=	(qb+1)*Fs/N;
    hBPi	=	zeros(Chno,N);
    hBPrms	=	zeros(1,Chno);
    mdept	=	zeros(1,Chno);
    ki		=	zeros(1,Chno-2);
    ri		=	zeros(1,Chno);
    Rframe  =   zeros(1,nWindows);
    
    for i = 1:nWindows %for each frame
        dataIn = frames(:,i); % get correct frame
        %%%%% BLOCK Calculate Excitation Patterns %%%%%
        TempIn =  dataIn*AmpCal;
        [rt,~]=size(TempIn);  % columns in temp not currently used
        [r,~]=size(a0); % columns in a0 not currently used
        if rt~=r; TempIn=TempIn'; end
        %maxAbsW=max(abs(fileHandle.windows.Blackman.wnd*AmpCal))
        %maxAbs=max(abs(TempIn))
        %TempIn=TempIn*10;
        TempIn	=	a0.*fft(TempIn); 
        Lg		=	abs(TempIn(qb)); % get absolute value of fourier transform for
                                     % indices in range of human hearing
        LdB		=	20*log10(Lg);%amp2db(Lg);      % convert to dB (20*log10(Lg))
        whichL	=	find(LdB>MinExcdB); % extract indices where FFT magnitudes  
                                        % exceed excitation threshold 
        sizL	=	length(whichL);  % get number of frequencies where this holds

        % steepness of slopes (Terhardt)
        S1 = -27; 
        S2 = zeros(1,sizL); % preallocate 

        for w = 1:1:sizL % loop w over frequency indices above threshold
          % Steepness of upper slope [dB/Bark] in accordance with Terhardt
          steep = -24-(230/freqs(w))+(0.2*LdB(whichL(w))); 
          if steep < 0
            S2(w) = steep; % set S2 with steepness value calculated earlier
          end
        end
        whichZ	= zeros(2,sizL); % preallocate
        qd		= 1:1:sizL; % indices of frequencies above excitation threshold
        whichZ(1,:)	= floor(2*Barkno(whichL(qd)+N01)); % get bark band numbers
        whichZ(2,:)	= ceil(2*Barkno(whichL(qd)+N01));

        %preallocate
        ExcAmp = zeros(sizL,47);
        Slopes = zeros(sizL,47);
        for k=1:1:sizL %loop over freq indices above threshold
          Ltmp = LdB(whichL(k)); % copy FFT magnitude (in dB) above threshold
          Btmp = Barkno(whichL(k)+N01); % and the bark number associated

          for l = 1:1:whichZ(1,k) % loop up to floored bark number of freq index k
            Stemp = (S1*(Btmp-(l*0.5)))+Ltmp; % Excitation level? 
                                              % -27(units)?*bark band + |FFT|
            if Stemp>MinBf(l) % provided this excitation is above the threshold 
              Slopes(k,l)= 10 .^ (0.05*Stemp);%db2amp(); % critical filterbank lower side
            end
          end
          for l = whichZ(2,k):1:47 % loop up to ceil'd bark number 
            Stemp =	(S2(k)*((l*0.5)-Btmp))+Ltmp;
            if Stemp>MinBf(l)
              Slopes(k,l) = 10 .^ (0.05*Stemp);%db2amp(); % critical filterbank upper side 
            end
          end
        end
        for k=1:1:47 % loop over each channel
          etmp = zeros(1,N); 
          for l=1:1:sizL % for each l index of fft bin in human hearing freq range 
            N1tmp = whichL(l); % get freq index of bin
            N2tmp = N1tmp + N01; 
            if (whichZ(1,l) == k)
              ExcAmp(N1tmp, k) = 1;
            elseif (whichZ(2,l) == k)
              ExcAmp(N1tmp, k) = 1;
            elseif (whichZ(2,l) > k)
              ExcAmp(N1tmp,k) = Slopes(l,k+1)/Lg(N1tmp);
            else
              ExcAmp(N1tmp,k) = Slopes(l,k-1)/Lg(N1tmp);
            end
            etmp(N2tmp) = ExcAmp(N1tmp,k)*TempIn(N2tmp);
          end % this is the excitation pattern
          % ifft to get time domain blocks of signal 
          ei(k,:)	= N*real(ifft(etmp)); 
          etmp	= abs(ei(k,:));
          h0(k)	= mean(etmp);
          Fei(k,:)	= fft(etmp-h0(k));
          hBPi(k,:)	= 2*real(ifft(Fei(k,:).*Hweight(k,:)));
          hBPrms(k)	= rms(hBPi(k,:));
          % get modulation depth according to Eq. 7 in D+W 
          if h0(k)>0
            mdept(k) = hBPrms(k)/h0(k);
            if mdept(k)>1
              mdept(k)=1; % clip limit modulation depth
            end
          else
            mdept(k)=0;
          end
        end
        % find cross-correlation coefficients
        for k=1:1:45
          cfac	=	cov(hBPi(k,:),hBPi(k+2,:));
          den	=	diag(cfac);
          den	=	sqrt(den*den');
          if den(2,1)>0
            ki(k)	=	cfac(2,1)/den(2,1);
          else
            ki(k)	=	0;
          end
        end

        % Calculate specific roughness ri and total roughness R
        % Eq. 8 in D+W
        ri(1)	=	(gzi(1)*mdept(1)*ki(1))^2;
        ri(2)	=	(gzi(2)*mdept(2)*ki(2))^2;
        for k = 3:1:45
          ri(k)	=	(gzi(k)*mdept(k)*ki(k-2)*ki(k))^2;
        end
        ri(46)	=	(gzi(46)*mdept(46)*ki(44))^2;
        ri(47)	=	(gzi(47)*mdept(47)*ki(45))^2;
        Rframe(i)		=	Cal*sum(ri); % roughness for this frame
        
    end
    
    R = mean(Rframe); % average roughness over all frames
     
    % ******** Annoyance *********    
    
    if S > 1.75
        ws = (S-1.75)*(0.25*log10(L+10));
    else
        ws = 0;
    end
    wfr = 2.18/(L^0.4)*(0.4*F+0.6*R);
    A = L * (1 + sqrt (ws^2 + wfr^2));
    
    if print
        fprintf('Loudness    = %6.3f \n',L)
        fprintf('Sharpness   = %6.3f \n',S)
        fprintf('Roughness   = %6.3f \n',R)
        fprintf('Fluctuation = %6.3f \n',F)
        fprintf('Annoyance   = %6.3f \n',A)
    end
    
    % outputs 
    res.R = R;
    res.S = S;
    res.L = L;
    res.F = F;
    res.A = A;
