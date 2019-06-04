

classdef rt_graficequal < rt_manipulator
    properties
        equalizer;
    end
    
    methods
        
        function obj=rt_graficequal(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Graphic Equalizer';
            pre_init(obj);  % add the parameter gui
            
            bands={'1 octave';'2/3 octave';'1/3 octave'};
            struc={'Cascade';'Parallel'};
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'EQOrder',2);
            addParameter(pars,'Bandwidth',bands{1});
            addParameter(pars,'Structure',struc{1});
            parse(pars,varargin{:});
            add(obj.p,param_number('EQOrder',pars.Results.EQOrder));
            add(obj.p,param_popupmenu('Bandwidth',pars.Results.Bandwidth,'list',bands));
            add(obj.p,param_popupmenu('Structure',pars.Results.Structure,'list',struc));
            set_listener(obj.p,obj);
            add(obj.p,param_button('change gains','button_text','open gui','button_callback_function','parameterTuner(param.parent.listener.equalizer);'));            
        end
        
        function post_init(obj) % called the second times around
            if ~isempty(obj.equalizer)
                release(obj.equalizer)
            end
            obj.equalizer = graphicEQ('SampleRate',obj.parent.SampleRate,...
                'EQOrder',getvalue(obj.p,'EQOrder'),...
                'Structure',getvalue(obj.p,'Structure'),...
                'Bandwidth',getvalue(obj.p,'Bandwidth'));
            
            
                        %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!

        end
        
        function sr=apply(obj,s)
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            sr =obj.equalizer(s);
        end
        
        function close(obj) 
            if ~isempty(obj.equalizer)
                release(obj.equalizer)
            end
        end
    end
    
end