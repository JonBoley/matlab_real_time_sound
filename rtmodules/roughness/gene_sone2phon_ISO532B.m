function phon = gene_sone2phon_ISO532B(sone)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% phon = gene_sone2phon_ISO532B(sone)
%
% Converts a sone value to a phon value
% according to the norm ISO532 B
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phon = 40 * sone.^0.35;

phon( sone>=1 ) = 40 + 10*log2( sone( sone>=1 ) );
 
  

