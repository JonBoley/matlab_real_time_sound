


classdef rt_reverb < rt_manipulator
    properties
        myrev;
    end
    
    methods
        
        function obj=rt_reverb(parent,varargin)
           obj@rt_manipulator(parent,varargin);
            obj.fullname='Reverberation';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'PreDelay',0.1);
            addParameter(pars,'Diffusion',0.5);
            addParameter(pars,'DecayFactor',0.5);
            addParameter(pars,'WetDryMix',0.3);
            parse(pars,varargin{:});
            add(obj.p,param_float_slider('PreDelay',pars.Results.PreDelay,'minvalue',0, 'maxvalue',1,'unittype',unit_time,'unit','msec'));
            add(obj.p,param_float_slider('Diffusion',pars.Results.Diffusion,'minvalue',0, 'maxvalue',1));
            add(obj.p,param_float_slider('DecayFactor',pars.Results.DecayFactor,'minvalue',0, 'maxvalue',1));
            add(obj.p,param_float_slider('WetDryMix',pars.Results.WetDryMix,'minvalue',0, 'maxvalue',1));            
           
        end
        
        function post_init(obj) % called the second times around
            obj.myrev = reverberator( ...                  %<--- new lines of code
                'SampleRate',obj.parent.SampleRate, ... %<---
                'WetDryMix',0.4);
           %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!
        end
        
        function sr=apply(obj,s)

            obj.myrev.PreDelay=getvalue(obj.p,'PreDelay');
            obj.myrev.Diffusion=getvalue(obj.p,'Diffusion');
            obj.myrev.DecayFactor=getvalue(obj.p,'DecayFactor');
            obj.myrev.WetDryMix=getvalue(obj.p,'WetDryMix');
            sr = obj.myrev(s);
            if size(s,2)==1
                sr=sr(:,1);
            end
        end
        
        function change_parameter(obj)
             gui(obj.p)
        end
    end
    
end