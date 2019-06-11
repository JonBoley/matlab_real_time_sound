function [MatNiv Fc Time] = ThirdOctave_levels(sig, fe, deltaT, P0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [MatNiv Fc Time] = ThirdOctave_levels(son,fe, deltaT, P0)
%
% FUNCTION
%       calculation of 1/3 octave levels in the 29 bands
%       by steps of deltaT seconds.
%       Band 1: fc = 25Hz, Band 29: fc = 16000Hz
%
%
% INPUT
%       sig = signal (Pa)
%       fe = sampling frequency (Hz)
%       deltaT = temporal step (s) for levels calculations (optional, default is 0.5s)
%                (=llength of window in which levels are calculated)
%       P0 = reference pressure (Pa) (optional, default is 2e-5)
% 
% OUTPUT
%       MatNiv= matric of levels (time x frequency)
%       Fc    = central frequencies of third octave bands (Hz)
%       Time  = time (s) at the center of the windows
%               
%
% CREDITS
%   Third octave filters used in this function are coming from a program
%   from Christophe Couvreur in MatlabCentral, and modified by Aaron Hastings,
%   Herrick Labs, from Purdue University in order to have better precision
%   at low frequencies (subsampling)
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - www.genesis.fr - 2009 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [MatNiv Fc Time] = ThirdOctave_levels(sig,fe, deltaT, P0)
%
% FONCTION
%       calcul des niveaux dans 29 bandes de tiers d'octave d'un signal
%       "sig" par pas de deltaT secondes
%       bande 1: fc = 25Hz, Bande 29: fc = 16000Hz
%
%
% ENTREES
%       sig = signal en Pa (vecteur)
%       fe = fr�quence d'�chantillonnage (scalaire)
%       deltaT = pas de temps en secondes pour le calcul des niveaux (optionnel, 0.5 par d�faut)
%                (=longueur de fen�tre sur laquelle on calcule les niveaux)
%       P0 = pression de r�f. (optionnel, 2e-5 par d�faut)
% 
% SORTIES
%       MatNiv= Matrice contenant les niveaux dans les 29 bandes de tiers d'octave
%               en ligne, et fen�tres temporelles de deltaT secondes en
%               colonnes
%       Fc    = fr�quences centrales des bandes de tiers d'octave (Hz)
%       Time  = temps (s) central des fen�tres
%               
%
% 
% Les filtres tiers d'octave utilis�s ici sont issus du programme de base de
% Christophe Couvreur, modifi� par Aaron Hastings, Herrick Labs, de Purdue
% University afin d'avoir une meilleure pr�cision BF par un sous-�chantillonage 
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - www.genesis.fr - janvier 2009 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pre-processing
if nargin < 4
    P0 = 2e-5; % Pa
end

if nargin < 3
    deltaT = 0.5; % seconds
end

% get IIR filters
Nbandes = 29;
StructFilt = ThirdOctave_Filters(fe); % structure of IIR for each band

Fc = zeros(1, Nbandes);
for k=1:Nbandes
    Fc(k) = StructFilt(k).Fc;
end

% initialisation
NbFrames = fix(length(sig)/(deltaT*fe));
sig = sig(:);
MatNiv = zeros(Nbandes, NbFrames);

Time = deltaT/2 : deltaT : (NbFrames-0.5)*deltaT;
      
%% calculation per window and band

for i = 1:Nbandes
    % resampling if necessary
    if fe ~= StructFilt(i).FS
        sig_tmp = resample(sig, StructFilt(i).FS, fe);
    else
        sig_tmp = sig;
    end

    % filtering
    sigFilt = filter(StructFilt(i).B, StructFilt(i).A, sig_tmp);

    % signal processing by windows
    L_frame = fix(deltaT*StructFilt(i).FS);
    NbFramesCurrentLoop = fix(length(sigFilt) / L_frame );
    % prare particular case
    if NbFramesCurrentLoop < NbFrames
        N = NbFramesCurrentLoop;
    else
        N = NbFrames;
    end
    
    % level in each temporal window
    for k = 1:N
        sig_frame = sigFilt((k-1)*L_frame+1:k*L_frame);
        MatNiv(i,k) = 10*log10( sum(sig_frame.^2) / L_frame / P0.^2);
    end
end
    


