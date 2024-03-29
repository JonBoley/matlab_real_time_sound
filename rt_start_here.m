%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% this script puts one large window up the screen that contains ALL modules
% to choose from, with three categories: manipulations, vizualizations and
% measurements as well as two windows.

clear all
close all force
clc
addpath(genpath('./rttools'));
addpath(genpath('./rtmodules'));
addpath(genpath('./thirdparty'));


obj=rt_full_gui;
init(obj);
run(obj);


