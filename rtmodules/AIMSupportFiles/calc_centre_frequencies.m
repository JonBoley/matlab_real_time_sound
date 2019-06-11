%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function centre_frequencies=calc_centre_frequencies(num_channels,lowFreq,highFreq)

EarQ = 9.26449;				%  Glasberg and Moore Parameters
minBW = 24.7;
centre_frequencies = -(EarQ*minBW) + exp((1:num_channels)'*(-log(highFreq + EarQ*minBW) + ...
    log(lowFreq + EarQ*minBW))/num_channels) * (highFreq + EarQ*minBW);
centre_frequencies=centre_frequencies(end:-1:1);
