
% loads a file and plays it and simulates simple hearing loss 


clear all
clc
close all force

addpath(genpath('./rttools'));
addpath(genpath('./rtmodules'));
addpath(genpath('./thirdparty'));


        % 25    32    40    50    63    79    100    126    158    200    250    316    398    501    631    794    1000    1259    1585    1995    2512    3162    3981    05012    6310    7943    10000    12589    15849    19953   
 gains='  0,    0,    0,    0,    0,    0,     0,     0,     0,     0,   -10,   -10,   -10,   -10,   -10,   -10,    -20,    -20,    -20,    -20,    -20,    -20,    -30,     -30,    -30,    -30,     -40,     -40,     -40,     -50';

       
filename='../randomwavs/BKBE0603.WAV';
[x,fs]=audioread(filename);

y=hl_sim(x,fs,gains);

soundsc(x,fs);
pause(length(x)/fs);
soundsc(y,fs);