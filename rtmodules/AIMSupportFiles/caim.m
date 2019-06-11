%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


%% class based auditory image model

classdef caim < handle
    properties
        % global sample_rate lowFreq highFreq num_channels
        sample_rate;
        num_channels;
        lowFreq;
        highFreq;
        window_length;   % frame length
        centre_frequencies;
        
        bmmmod;
        napmod;
        strobesmod;
        saimod;
        mode;
        
    end
    
    methods
        function obj=caim(sample_rate,num_channels,lowFreq,highFreq,window_length,mode)  % initialization
            if nargin < 6
                mode='SAI';
            end
            if nargin < 5
                window_length=128;
            end
            if nargin < 4
                highFreq=8000;
            end
            if nargin < 3
                lowFreq=100;
            end
            if nargin < 2
                num_channels=50;
            end
            if nargin < 1
                sample_rate=1/16000;
            end
            obj.mode=mode;
            obj.sample_rate=sample_rate;
            obj.num_channels=num_channels;
            obj.lowFreq=lowFreq;
            obj.highFreq=highFreq;
            obj.window_length=window_length;
            
            obj.centre_frequencies=calc_centre_frequencies(num_channels,lowFreq,highFreq);
            
            if isequal(obj.mode,'BMM') || isequal(obj.mode,'NAP') ||isequal(obj.mode,'STROBES') || isequal(obj.mode,'SAI')
%                 obj.bmmmod=caim_bmm(obj); % init
                obj.bmmmod=gammatoneFilterBank([obj.lowFreq obj.highFreq],obj.num_channels,1/sample_rate);
            end
            if isequal(obj.mode,'NAP') ||isequal(obj.mode,'STROBES') || isequal(obj.mode,'SAI')
                obj.napmod=caim_nap(obj); % init
            end
            if isequal(obj.mode,'STROBES') || isequal(obj.mode,'SAI')
                obj.strobesmod=caim_strobes(obj); % init
            end
            if isequal(obj.mode,'SAI')
                obj.saimod=caim_sai(obj); % init
            end
        end
        
        function obj=setmode(obj,mode)
            obj.mode=mode;
            
        end
        
        function [viz1,viz2,viz3,viz4]=step(obj,sig)
            % calculate
            if isequal(obj.mode,'BMM') || isequal(obj.mode,'NAP') ||isequal(obj.mode,'STROBES') || isequal(obj.mode,'SAI')
                out=step(obj.bmmmod,sig);
                viz1=out;
            end
            if isequal(obj.mode,'NAP') ||isequal(obj.mode,'STROBES') || isequal(obj.mode,'SAI')
                obj.napmod=step(obj.napmod,out');
                viz2=obj.napmod.buffer;
            end
            if isequal(obj.mode,'STROBES') || isequal(obj.mode,'SAI')
                obj.strobesmod=step(obj.strobesmod,obj.napmod.buffer);
                viz3=obj.strobesmod.strobes;
            end
            if isequal(obj.mode,'SAI')
                obj.saimod=step(obj.saimod,obj.strobesmod.strobes,obj.napmod.buffer);
                viz4=obj.saimod.buffer;
            end
            
        end
        
        
        function obj=change_parameter(obj)
        end
        
    end
    
end

