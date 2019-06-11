%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)




classdef rt_flanger< rt_manipulator
    properties
        myflanger
    end
    
    methods
        
        function obj=rt_flanger(parent,varargin)
            obj@rt_manipulator(parent,varargin);  % superclass contructor
            obj.fullname='Flanger'; % full name identifies it later on the screen
            pre_init(obj);  % add the parameter gui
            
            
            
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'Delay',0.001);
            addParameter(pars,'Depth',30);
            addParameter(pars,'Rate',0.25);
            addParameter(pars,'FeedbackLevel',0.4);
            addParameter(pars,'WetDryMix',0.5);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('Delay',pars.Results.Delay,'minvalue',0, 'maxvalue',0.1));
            add(obj.p,param_float_slider('Depth',pars.Results.Depth,'minvalue',0, 'maxvalue',50));
            add(obj.p,param_float_slider('Rate',pars.Results.Rate,'minvalue',0, 'maxvalue',0.5));
            add(obj.p,param_float_slider('FeedbackLevel',pars.Results.FeedbackLevel,'minvalue',0, 'maxvalue',1));
            add(obj.p,param_float_slider('WetDryMix',pars.Results.WetDryMix,'minvalue',0, 'maxvalue',1));
            
            s='Flanger is wrapper of Matlab function audioexample.';
            s=[s 'Flanger as described here:https://uk.mathworks.com/help/audio/examples/delay-based-audio-effects.html.'];
            s=[s 'General information about flangers: https://en.wikipedia.org/wiki/Flanging'];
            s=[s '%   Delay         - Base delay in seconds'];
            s=[s '%   Depth         - Amplitude of modulator'];
            s=[s '%   Rate          - Frequency of modulator'];
            s=[s '%   FeedbackLevel - Feedback gain'];
            s=[s '%   WetDryMix     - Wet to dry signal ratio'];
            
            obj.descriptor=s;
            
        end
        
        function post_init(obj) % called the second times around
            set_changed_status(obj.p,0);
            
            %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
            sync_initializations(obj); % in order to catch potential other modules that need to be updated!
            Delay=getvalue(obj.p,'Delay');
            Depth=getvalue(obj.p,'Depth');
            Rate=getvalue(obj.p,'Rate');
            FeedbackLevel=getvalue(obj.p,'FeedbackLevel');
            WetDryMix=getvalue(obj.p,'WetDryMix');
            
            obj.myflanger=audioexample.Flanger('SampleRate',obj.parent.SampleRate,'Delay',Delay,'Depth',Depth,'Rate',Rate,'FeedbackLevel',FeedbackLevel,'WetDryMix',WetDryMix);
        end
        
        function sr=apply(obj,s)
            %             if has_changed(obj.p)
            %                 Delay=getvalue(obj.p,'Delay');
            %                 Depth=getvalue(obj.p,'Depth');
            %                 Rate=getvalue(obj.p,'Rate');
            %                 FeedbackLevel=getvalue(obj.p,'FeedbackLevel');
            %                 WetDryMix=getvalue(obj.p,'WetDryMix');
            
            if has_changed(obj.p)
                obj.myflanger.Delay =getvalue(obj.p,'Delay');
                obj.myflanger.Rate=getvalue(obj.p,'Rate');
                obj.myflanger.Depth=getvalue(obj.p,'Depth');
                obj.myflanger.WetDryMix=getvalue(obj.p,'WetDryMix');
                obj.myflanger.FeedbackLevel=getvalue(obj.p,'FeedbackLevel');
                
                set_changed_status(obj.p,0);
            end
            
            sr=obj.myflanger(s);
        end
        
        
    end
    
end
