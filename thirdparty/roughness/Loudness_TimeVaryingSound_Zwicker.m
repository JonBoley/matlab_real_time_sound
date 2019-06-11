function res = Loudness_TimeVaryingSound_Zwicker(signal, FS, type, fieldtype, x_ratio, t_duration, show)

%%%%%%%%%%%%%
% FUNCTION:
%   Calculation of loudness for time-varying sounds, following the model of
%   Zwicker and Fastl (1999).
%   See reference for more details.
%
% USE:
%   res = Loudness_TimeVaryingSound_Zwicker(signal, FS, type, fieldtype, x_ratio, t_duration, show)
% 
% INPUT:
%   signal    : acoustic signal, monophonic (Pa)
%   FS        : sampling frequency (Hz)
%   type      : (optional parameter) 'mic' (default value) for omnidirectional sound
%               recording, 'head' for dummy head measurement
%   fieldtype : 'free' (default) for free field, 'diffuse' for diffuse field
%   x_ratio   : percentage x used to compute Nx and Lx (percent) - default value is 5 % - see output
%   t_duration: duration t used to compute Nt and Lt (second) - default value is 0.030 sec. - see output
%   show      : optional parameter for some figures display.
%            May be false (disable, default value) or true (enable).
% 
% OUTPUT:
%   res    : structure which contains the following fields:
%             - barkAxis : vector of Bark band numbers used for specific loudness computation
%             - time : time vector in seconds
%             - InstantaneousLoudness: instantaneous loudness (sone) vs time
%             - Nmax : maximum of instantaneous loudness (sone)
%             - Nx   : loudness exceeded during x percent of the signal (x is
%               the value of the input variable named x_ratio)
%             - Nt   :  loudness exceeded during t seconds of the signal (t is
%               the value of the input variable named t_duration)
%             - InstantaneousLoudnessLevel: instantaneous loudness level (phon) vs time
%             - Lmax : maximum of instantaneous loudness level (sone)
%             - Lx   : loudness level exceeded during x percent of the signal (x is
%               the value of the input variable named x_ratio)
%             - Lt   : loudness level exceeded during t seconds of the signal (t is
%               the value of the input variable named t_duration)
%             - InstantaneousSpecificLoudness: specific loudness (sone/ERB) vs time and frequency
%             - Sx   : Sharpness level exceeded x_ratio percent of the signal.
%   

% not implemented / deprecated from above.
%             - LTL: long-term loudness (sone) vs time
%             - STLmax: max of STL value (sone)
%             - LTLmax: max of LTL value (sone) 
%             - InstantaneousLoudnessLevel: instantaneous loudness level (phon) vs time
%             - STLlevel: short-term loudness level (phon) vs time
%             - LTLlevel: long-term loudness level (phon) vs time
%             - STLlevelmax: max of STL level value (phon)
%             - LTLlevelmax: max of LTL level value (phon)

% REFERENCE: 
% Zwicker E. et Fastl H., "Psychoacoustics: Facts and models",
% 2nd Edition, Springer-Verlag, Berlin, 1999
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
% function res = sonie_NonStationnaire_Zwicker(signal, FS, type, show)
%
% Calcul de la sonie d'un son de sonie variable dans le temps selon la
% proc�dure propos�e par fastl (d�riv� de Zwicker strationnaire) avec
% correction de Munich
%
% Entr�es:
%   signal  :  signal en Pa
%   FS      :  fr�quence d'�chantillonnage en Hz
%   type    :  type de prise de son ( 'mic' ou 'head' ) ('mic' par d�faut)
% fieldtype :  'free' ou 'diffuse' selon le cas ('free' par d�faut)
%   show    :  si show = true affichage des figures (false par d�faut)
%
% Sorties:
%   res.phonieMax: max de la phonie instantan�e
%   res.phonieN5: niveau de phonie d�pass�e pendant 5 % du temps 
%       (seuil sur sones puis conversion en phones)
%
% Fonction cr��e � partir de la fonction fastl.m - 2009
%
% r�f: Zwicker E. et Fastl H., "Psychoacoustics: Facts and models",
%      2nd Edition, Springer-Verlag, Berlin, 1999


%% Pre-processing

if nargin < 2
    disp('Type: help Loudness_TimeVaryingSound_Zwicker')
    error('Not enough arguments');
end;

if nargin < 3  % default is microphone measure
    type = 'mic'; 
end

if nargin < 4  % default sound filed type is 'free'
    fieldtype = 'free';
end;

if nargin < 5  % default x_ratio
    x_ratio = 5; % 5 percent
end;

if nargin < 6  % default t_duration
    t_duration = 0.030;  % 30ms
end;

if nargin < 7  % disable display
    show = false; 
end;

sig = signal(:);
fs = FS;


%% Parameters and constant settings

dt   = 0.002;   % temporal step for calculations (seconds)
tfen = 0.002;   % analysis window length (seconds)

% Quadripole constants
R1 = 35e3; % Ohm
R2 = 20e3; % Ohm
C1 = 0.7e-6; % Farad
C2 = 1e-6; % Farad

T1 = R1*C1;
T2 = R2*C2;
T3 = R1*(C1+C2);

% Definitions for elliptic filters which will be designed
% Design is made in order to have same power in the bands Fc
% as when using an FFT of length 48000 on a white noise 

% Ranges of 1/3 octave band levels for correction at low frequencies
% according to equal loudness contours
rap = [45 55 65 71 80 90 100 120 ];

% Correction of critical band levels at low frequencies according to 
% equal loudness contours within the eight ranges defined by RAP
dll = [-32 -24 -16 -10 -5 0 -7 -3 0 -2 0;
    -29 -22 -15 -10 -4 0 -7 -2 0 -2 0;
    -27 -19 -14 -9 -4 0 -6 -2 0 -2 0;
    -25 -17 -12 -9 -3 0 -5 -2 0 -2 0;
    -23 -16 -11 -7 -3 0 -4 -1 0 -1 0;
    -20 -14 -10 -6 -3 0 -4 -1 0 -1 0;
    -18 -12 -9 -6 -2 0 -3 -1 0 -1 0;
    -15 -10 -8 -4 -2 0 -3 -1 0 -1 0];

    
% Critical band rate level at absolute threshold without taking into
% account the transmission characteristics of the ear
les = [30 18 12 8 7 6 5 4 3 3 3 3 3 3 3 3 3 3 3 3];

% Correction of levels according to the transmission characteristics of the ear
ao = [ 0 0 0 0 0 0 0 0 0 0 -0.5 -1.6 -3.2 -5.4 -5.6 -4 -1.5 2 5 12];

% Level differences between free and diffuse sound fields
DDF = [0 0 0.5 0.9 1.2 1.6 2.3 2.8 3 2 0 -1.4 -2 -1.9 -1 0.5 3 4 4.3 4];

% Adaptation of 1/3 octave band levels to the corresponding critical band levels (DCB)
dlt = [-0.25 -0.6 -0.8 -0.8 -0.5 0 0.5 1.1 1.5 1.7 1.8 1.8 1.7 1.6 1.4 1.2 0.8 0.5 0 -0.5]; 

% Range of specific loudness for the determination of the steepness of the
% upper slopes in the specific loudness - critical band rate pattern (RNS)
lim = [21.5 18 15.1 11.5 9 6.1 4.4 3.1 2.13 1.36 0.82 0.42 0.30 0.22 0.15 0.10 0.035 0];
    
% Steepness of the upper slopes in the specific loudness - critical band
% rate pattern for the ranges RNS as a function of the number of the
% critical band (USL)
fls =  [13 8.2 6.3 5.5 5.5 5.5 5.5 5.5;
    9 7.5 6 5.1 4.5 4.5 4.5 4.5;
    7.8 6.7 5.6 4.9 4.4 3.9 3.9 3.9;
    6.2 5.4 4.6 4.0 3.5 3.2 3.2 3.2;
    4.5 3.8 3.6 3.2 2.9 2.7 2.7 2.7;
    3.7 3.0 2.8 2.35 2.2 2.2 2.2 2.2;
    2.9 2.3 2.1 1.9 1.8 1.7 1.7 1.7;
    2.4 1.7 1.5 1.35 1.3 1.3 1.3 1.3;
    1.95 1.45 1.3 1.15 1.1 1.1 1.1 1.1;
    1.5 1.2 0.94 0.86 0.82 0.82 0.82 0.82;
    0.72 0.67 0.64 0.63 0.62 0.62 0.62 0.62;
    0.59 0.53 0.51 0.50 0.42 0.42 0.42 0.42;
    0.40 0.33 0.26 0.24 0.24 0.22 0.22 0.22;
    0.27 0.21 0.20 0.18 0.17 0.17 0.17 0.17;
    0.16 0.15 0.14 0.12 0.11 0.11 0.11 0.11;
    0.12 0.11 0.10 0.08 0.08 0.08 0.08 0.08;
    0.09 0.08 0.07 0.06 0.06 0.06 0.06 0.05;
    0.06 0.05 0.03 0.02 0.02 0.02 0.02 0.02];
    
% Upper limits of approximated critical bands in terms of critical band rate
ZUP  = [0.9 1.8 2.8 3.5 4.4 5.4 6.6 7.9 9.2 10.6 12.3 13.8 15.2 16.7 18.1 19.3 20.6 21.8 22.7 23.6 24]; 
    
% add some silence at the end of the signal
sig(end : round( end + 0.3 * fs + tfen * fs)) = 0;

pts = length(sig);                  % nb of samples
step = round(fs * dt);              % number of samples between two calculations of loudness
ncl = fix(pts/(dt*fs));             % number of samples of output from calculation
t = (0 : ncl-1) * step + 1;         % index of the calculation windows start
res.time = t / fs;                  % time vector


%% Compute Third Octave Levels
[VectNiv3Oct, ~] = ThirdOctave_levels(sig,fs,dt,2e-5);

%Keep the 28 first bands
ncl=size(VectNiv3Oct,2);
VectNiv3Oct = VectNiv3Oct(1:28,:);

xiq=zeros(ncl,21); % frame for third octave 


%% Loudness computation

% main loudness for ncl points
for q = 1 : ncl
    
    %% Correction of 1/3 octave band levels according to equal loudness
% contours (XP) and calculation of the intensities for 1/3 octave bands up
% to 315Hz
    TI = zeros(1, size(dll,2));
    for i = 1:size(dll,2)
    
        j = 1;
        while ( (VectNiv3Oct(i,q) > rap(j) - dll(j,i)) && j < 8 )
            j = j+1;
        end;
    
        XP = VectNiv3Oct(i,q) + dll(j,i);
        TI(i) = 10^(XP/10);
    
    end;

%% Determination of levels (LCB) within the first three critical bands
    GI = zeros(3,1);
    GI(1) = sum(TI(1:6));   % sum of 6 third octave bands from 25 Hz to 80 Hz
    GI(2) = sum(TI(7:9));   % sum of 3 third octave bands from 100 Hz to 160 Hz
    GI(3) = sum(TI(10:11)); % sum of 2 third octave bands from 200 Hz to 250 Hz

    FNGI = 10*log10(GI);
    LCB = zeros(length(GI),1);

    for i = 1:length(GI)
        if GI(i) > 0
            LCB(i) = FNGI(i);
        end
    end
    
    le = [LCB' VectNiv3Oct(size(dll,2)+1:size(VectNiv3Oct,1),q)'];
    
    
    switch type
        case 'mic'  % Microphone: outer ear correction is used
            le = (le' - ao')';

        case 'head' % Dummy head: ear correction is already taken into the recording
            le = (le')';

        otherwise
            error('"type" parameter is not valid');

    end;

    % Zwicker constants
    No = 0.0635;
    k = 0.25;
    s = 0.25;
    
    % Main loudness calculation
    F = No *(10.^(k .* les / 10));
    
    % field type corrections
    switch fieldtype
        case 'free'
            krn = F' .* (((1 - s) + s * (10.^(0.1 * (le' - dlt' - les')))).^k - 1);
            
        case 'diffuse'
            krn = F' .* (((1 - s) + s * (10.^(0.1 * (le' - dlt' + DDF' - les')))).^k - 1);
            
        otherwise
            error('"fieldtype" parameter is not valid');
    end;
    
    
    
    krn( le < les ) = 0; % loudness values inferior to threshold are set to zero
    krn( krn < 0 ) = 0;
    
    % correction of specific loudness within the first critical band taking
    % into account the dependence of absolute threshold within the band
    korry = 0.4 + 0.32 * krn(1)^0.2;
    
    if korry > 1 
        korry = 1; 
    end
    
    krn(1) = krn(1) * korry;
    xiq( q, 1 : 21) = [krn' 0]; % store calculation result
end

%% Quadripol temporal response for main loudness

p = (T2 + T3) / (T1 * T2);
q = 1 / (T1 * T2);
lam1 = - p / 2 + sqrt(p * p / 4 - q);
lam2 = - p / 2 - sqrt(p * p / 4 - q);
den = T2 * (lam1 - lam2);
e1 = exp(lam1 * dt);
e2 = exp(lam2 * dt);
B0 = (e1 - e2) / den;
B1 = ((T2 * lam2 + 1) * e1 - (T2 * lam1 + 1) * e2) / den;
B2 = ((T2 * lam1 + 1) * e1 - (T2 * lam2 + 1) * e2) / den;
B3 = (T2 * lam1 + 1) * (T2 * lam2 + 1) * (e1 - e2) / den;
B4 = exp(- dt / T3);
B5 = exp(- dt / T2);
niq = zeros( ncl, 21);

for i = 1:21
    ui = xiq( :, i);
    u0 = 0;
    u2 = 0;
    
    for q = 1 : ncl
        if ui(q) < u0
            if u0 > u2
                u0dt = u0 * B2 - u2 * B3;
                u2dt = u0 * B0 - u2 * B1;
            else
                u0dt = u0 * B4;
                u2dt = u0dt;
            end;
            
        else
        u0dt = ui(q);
            if u0dt > u2
                u2dt = (u2 - ui(q)) * B5 + ui(q);
            else
               u2dt = ui(q);
            end;
        end;
        
        if ui(q) > u0dt
            u0dt = ui(q);
        end;
        
        if u2dt > u0dt
            u2dt = u0dt;
        end;
        
        u0 = u0dt;
        u2 = u2dt;
        niq( q, i) = u0;
    end;
end;

prec = 10;  % frequency axis sampling
BarkStep=1/10;
InstantaneousSpecificLoudness = zeros(ncl, 24*prec);
n_tot = zeros(1, ncl);
% loudness is processed for each q
for q = 1:ncl
    
    krn = niq( q, :);
    ns = zeros( 1, 24*prec);
    N = 0;
    Z1 = 0;
    N1 = 0;
    IZ = 1;
    Z = 0.1;
    
    for i = 1:21  % specific loudness
        ZUP(i) = ZUP(i);
        IG = i - 1;

        if IG > 8  % steepness of upper slope (USL) for bands above 8th one are identical
         IG = 8;
        end;

        while Z1 < ZUP(i)
    
            if N1 <= krn(i)
               % contribution of unmasked main loudness to total loudness
               % and calculation of values 
                if N1 < krn(i)
                    j=1;
                
                    while (lim(j) > krn(i)) && (j < 18) % determination of the number j corresponding
                        j = j+1;                         % to the range of specific loudness
                    end;
                
                end;

                Z2 = ZUP(i);
                N2 = krn(i);
                N = N + N2*(Z2-Z1);
                k = Z;                     % initialisation of k
            
                while (k <= Z2)
                    ns(IZ) = N2;
                    IZ = IZ + 1;                           
                    k = k+BarkStep;
                end;
            
                Z = k; 
            
            else %if N1 > NM(i)
             % decision wether the critical band in question is completely
             % or partly masked by accessory loudness

                N2 = lim(j);

                if N2 < krn(i)
                    N2 = krn(i);
                end;
            
                DZ = (N1-N2) / fls(j,IG);
                Z2 = Z1 + DZ;                                        

                if Z2 > ZUP(i)
                    Z2 = ZUP(i);
                    DZ = Z2 - Z1;
                    N2 = N1 - DZ*fls(j,IG);
                end;
            
                N = N + DZ*(N1+N2)/2;
                k = Z;                     % initialisation of k
            
                while (k <= Z2)
                    ns(IZ) = N1 - (k-Z1)*fls(j,IG);
                    IZ = IZ + 1;
                    k = k+BarkStep;
                end;
            
                Z = k; 

            end;
            
            if (N2 <= lim(j)) && (j < 18)
                j = j + 1;
            end;
        
            if (N2 <= lim(j)) && (j >= 18)
                j = 18;
            end;

            Z1 = Z2;     % N1 and Z1 for next loop
            N1 = N2;




        end;
    end;
    n_tot(q) = N;     % total loudness at current time q
    InstantaneousSpecificLoudness(q,:) = ns;
end;


% output storage
res.InstantaneousSpecificLoudness = InstantaneousSpecificLoudness(:,:);

res.barkAxis = 0.1:BarkStep:24; % frequency vector


%% Filtering to get Instantaneous loudness

fecl = round(fs / step);
[b, a] = butter( 3, 1000 / (20 * pi * fecl));
nq = filter( b, a, n_tot);
res.InstantaneousLoudness = nq;
res.Nmax = max(nq);


%% Conversion from sone to phon

phq = gene_sone2phon_ISO532B(nq);

phq( phq < 0 ) = 0;
phq( phq < 3 ) = 3;

res.InstantaneousLoudnessLevel = phq;
res.Lmax = max(phq); 



%% Nx computation
X_index = floor( (100-x_ratio)/100 * ncl );
nq_sort = sort( nq );
Nx = nq_sort( X_index );

res.Nx = Nx;


%% Nt computation
p_t = t_duration / dt;
X_index = ncl - p_t;
Nt = nq_sort( X_index );

res.Nt = Nt;

%% Lx computation
X_index = floor( (100-x_ratio)/100 * ncl );
nq_sort = sort( phq );
Lx = nq_sort( X_index );

res.Lx = Lx;

%% Lt computation
p_t = t_duration / dt;
X_index = ncl - p_t;
Lt = nq_sort( X_index );

res.Lt = Lt;


%% Optional displays

if show == true
    figure;
    t = (0 : length(sig)-1) ./ fs;
    xmax = res.time(end);
    subplot( 3, 1, 1), plot( t, sig); ax = axis; axis([0 xmax ax(3) ax(4)]); 
        title('Signal'); ylabel('Amplitude (Pa)');
    subplot( 3, 1, 2), plot( res.time, res.InstantaneousLoudnessLevel); 
    ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('Instantaneous Loudness Level'); ylabel('Loudness level (phon)'); grid on;
        text(res.time(end) * 0.7, res.Lmax - 10, sprintf('Lmax = %.4f',res.Lmax));
    subplot( 3, 1, 3), plot( res.time, res.InstantaneousLoudness);
    ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('Instantaneous Loudness'); xlabel('Time (s)');
        ylabel('Loudness (sone)'); grid on;
        text(res.time(end) * 0.7, res.Nmax ./ 2, sprintf('Nmax = %.3f',res.Nmax));
    
    figure;
    mesh(res.time, res.barkAxis, res.InstantaneousSpecificLoudness'); view( 60, 60);
        title('Instantaneous Specific Loudness'); xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        zlabel('Specific loudness (sone/Hz)');
end

%% Sharpness Calculation 
% Measure of instantaneous sharpness
% Uses the Zwicker model of sharpness from Psychoacoustics: Facts and Models
% Daniel Wallace - djw1g12@soton.ac.uk

n = length(t); % number of temporal bins. 
c = 0.11; % factor to scale sharpness to 1 acum for a 60dB 1kHz critical band tone
Nprime = InstantaneousSpecificLoudness;  % Matrix of loudness per bark band and per 0.02 second 
barkAxis = 0.1:BarkStep:24; % 
InstantaneousSharpness = zeros(1,n); % initialise array - same size as InstantaneousLoudness
g = @(z) 1.*(z<=14)+(0.00012.*z.^4 - 0.0056.*z.^3 + 0.1.*z.^2 - 0.81.*z + 3.51).*(z>14);
% g(z) is defined in Zwicker and Fastl - Psychoacoustics: Facts and Models 
% This weights each bark band's contribution to sharpness towards high frequencies.
for i = 1:n %for each time period
    InstantaneousSharpness(i) = c*sum(Nprime(i,:).*g(barkAxis).*barkAxis)./sum(Nprime(i,:));
end
res.InstantaneousSharpness = InstantaneousSharpness; % save to results structure

% calculate sharpness exceeded x_ratio percent of the signal duration 
S_index = floor((100-x_ratio)/100 * ncl ); % index which meets x_ratio percent of length
nq_sort = sort( InstantaneousSharpness ); % sort fragments in order of sharpness
Sx = nq_sort( S_index ); % value exceeded x_ratio percent of the time
res.Sx = Sx; % save to results structure

% http://pub.dega-akustik.de/IN2016/data/articles/000063.pdf says 
% that arithmetic mean of instantaneous sharpness gives best correlation 
% with subjective tests compared to max (~95th centile) and geometric mean 
% res.Sx = mean(res.InstantaneousSharpness,'omitnan');

