


classdef rt_chorus< rt_manipulator
    properties
        mychorus
    end
    
    methods
        
        function obj=rt_chorus(parent,varargin)
            obj@rt_manipulator(parent,varargin);  % superclass contructor
            obj.fullname='Chorus'; % full name identifies it later on the screen
            pre_init(obj);  % add the parameter gui
                    

            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'Delay',0.02);
            addParameter(pars,'Depth1',0.01);
            addParameter(pars,'Rate1',0.01);            
            addParameter(pars,'Depth2',0.03);
            addParameter(pars,'Rate2',0.02);
            addParameter(pars,'WetDryMix',0.5);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('Delay',pars.Results.Delay,'minvalue',0, 'maxvalue',0.1));
            add(obj.p,param_float_slider('Depth1',pars.Results.Depth1,'minvalue',0, 'maxvalue',50));
            add(obj.p,param_float_slider('Rate1',pars.Results.Rate1,'minvalue',0, 'maxvalue',10));
            add(obj.p,param_float_slider('Depth2',pars.Results.Depth2,'minvalue',0, 'maxvalue',50));
            add(obj.p,param_float_slider('Rate2',pars.Results.Rate2,'minvalue',0, 'maxvalue',10));
            add(obj.p,param_float_slider('WetDryMix',pars.Results.WetDryMix,'minvalue',0, 'maxvalue',1));
        
             s='Chorus is wrapper of Matlab function audioexample.Flanger as described here: ';
             s=[s 'https://uk.mathworks.com/help/audio/examples/delay-based-audio-effects.html'];
             s=[s 'The chorus effect usually has multiple independent delays, each modulated'];
            s=[s 'by a low-frequency oscillator. '];
            s=[s 'audioexample.Chorus> implements this effect. The block diagram shows a'];
            s=[s 'high-level implementation of a chorus effect.'];
            s=[s 'The chorus effect example has six tunable parameters that can be modified'];
            s=[s 'while the simulation is running:'];
            s=[s '* Delay - Base delay applied to audio signal, in seconds'];
            s=[s '* Depth 1 - Amplitude of modulator applied to first delay branch'];
            s=[s '* Rate 1 - Frequency of modulator applied to first delay branch, in Hz'];
            s=[s '* Depth 2 - Amplitude of modulator applied to second delay branch'];
            s=[s '* Rate 2 - Frequency of modulator applied to second delay branch, in Hz'];
            s=[s '* WetDryMix - Ratio of wet signal added to dry signal'];

            obj.descriptor=s;
        end
        
        function post_init(obj) % called the second times around
            set_changed_status(obj.p,0);
            
                        %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!
                Delay=getvalue(obj.p,'Delay');
                Depth1=getvalue(obj.p,'Depth1');
                Rate1=getvalue(obj.p,'Rate1');
                Depth2=getvalue(obj.p,'Depth2');
                Rate2=getvalue(obj.p,'Rate2');
                WetDryMix=getvalue(obj.p,'WetDryMix');
                
                obj.mychorus=audioexample.Chorus('SampleRate',obj.parent.SampleRate,'Delay',Delay, ...
                    'Depth',[Depth1 Depth2],...
                    'Rate',[Rate1 Rate2],...
                    'WetDryMix',WetDryMix);
        end
        
        function sr=apply(obj,s)

                sr=obj.mychorus(s);
        end
        
        
    end
    
end