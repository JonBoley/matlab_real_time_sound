%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef rt_pitchshifter< rt_manipulator
    properties
        overlap;
        PitchShift;
    end
    
    methods
        
        function obj=rt_pitchshifter(parent,varargin)
            obj@rt_manipulator(parent,varargin{:});  % superclass contructor
            obj.fullname='Delay-Based Pitch Shifter'; % full name identifies it later on the screen
            pre_init(obj);  % add the parameter gui
            
            obj.PitchShift=8;
            obj.overlap=0.3;
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'PitchShift',obj.PitchShift);
            addParameter(pars,'overlap',obj.overlap);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('PitchShift',pars.Results.PitchShift,'minvalue',-12, 'maxvalue',12));
            add(obj.p,param_float_slider('overlap',pars.Results.overlap,'minvalue',0, 'maxvalue',1));
            obj.descriptor='pitch shifter is implemented from this mathworks code: https://uk.mathworks.com/help/audio/examples/delay-based-pitch-shifter.html';
        end
        
        function post_init(obj) % called the second times around
            set_changed_status(obj.p,0);
            
                        %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!

        end
        
        function sr=apply(obj,s)
%             if has_changed(obj.p)
                obj.PitchShift=getvalue(obj.p,'PitchShift');
                obj.overlap=getvalue(obj.p,'overlap');
                
%   Copyright 2019 Stefan Bleeck, University of Southampton
            [sr,delays,gains] = shiftPitch(s,obj.PitchShift,obj.overlap,obj.parent.SampleRate);
            
            
        end
        
        
    end
    
end
