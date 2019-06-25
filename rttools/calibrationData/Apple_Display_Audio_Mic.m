% Input calibration for realtime sound platform (github:sbleeck/matlab_real_time_sound)
% performed by Stefan Bleeck

% 25-Jun-2019
%
calib.bandwidth='1/3 octave';
calib.preferred_frequencies=[ 25.0 31.5 40.0 50.0 63.0 80.0 100.0 125.0 160.0   200.0 250.0 315.0 400.0 500.0 630.0 800.0 1000.0 1250.0 1600.0 2000.0 2500.0 3150.0 4000.0 5000.0 6300.0 8000.0 10000.0 12500.0 16000.0 20000.0];
calib.gains=[                 15.0 15.0 15.0 15.0 15.0 15.0  15.0  15.0  15.0    15.0  15.2  13.0  14.6  17.4  14.3  18.5  20.0    12.5   14.4   15.7   19.8   22.1   23.6   16.7   21.0   20.0   23.7     13.0    14.0 14.0];
