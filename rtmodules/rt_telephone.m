%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef rt_telephone < rt_manipulator
    properties
        a;
        b;
        zi;
    end
    
    methods
        
        function obj=rt_telephone(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Telephone';
            pre_init(obj);  % add the parameter gui
            
            s='simple bandpass filter implementing a phone filter 300-3400 telephone bandwidth ';
            s=[s, 'implementation from Mike Brookes via mathwork central. '];
            s=[s, 'The filter meets the specifications of G.151 for any sample frequency and has a gain of -3dB at the passband edges.'];

            obj.descriptor=s;
            
        end
        
        function post_init(obj) % called the second times around
            
            [obj.b,obj.a]=phone_filter(obj.parent.SampleRate);
            obj.zi=zeros(length(obj.b)-1,1);
        end
        
        function sr=apply(obj,sig)
            [sr,obj.zi]=filter(obj.b,obj.a,sig,obj.zi);
        end
        
    end
    
end