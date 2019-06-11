% to determine the AI weights @ sampling rate 'Fs' and splited bands 'BAND'
function [fcenter,ANSIs]=get_ANSIs(fcenter)
% =(BAND(1:end-1)+BAND(2:end))/2;

%% Data from Table B.1 in "ANSI (1997). S3.5–1997 Methods for Calculation of the Speech Intelligibility
%% Index. New York: American National Standards Institute."
f=[150 250 350 450 570 700 840 1000 1170 1370 1600 1850 2150 2500 2900 3400 4000 4800 5800 7000 8500];
BIF=[0.0192 0.0312 0.0926 0.1031 0.0735 0.0611 0.0495 0.0440 0.0440 0.0490 0.0486 0.0493 0.0490 0.0547 0.0555 0.0493 0.0359 0.0387 0.0256 0.0219 0.0043];

ANSIs= interp1(f,BIF,fcenter);