%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



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
            addParameter(pars,'Gains','0,0,0,0,0,0,0,0,0,0');
            
            parse(pars,varargin{:});
            add(obj.p,param_number('EQOrder',pars.Results.EQOrder));
            add(obj.p,param_popupmenu('Bandwidth',pars.Results.Bandwidth,'list',bands));
            add(obj.p,param_popupmenu('Structure',pars.Results.Structure,'list',struc));
            add(obj.p,param_generic('Gains',pars.Results.Gains));
            set_listener(obj.p,obj);
            add(obj.p,param_button('change gains','button_text','open gui','button_callback_function','display_equalizer(param.button_target);','button_target',obj));
            
            s='Graphic equalizer - standards-based graphic equalizer  ';
            s=[s 'implements the matlab function graphicEQ  '];
            s=[s 'https://uk.mathworks.com/help/audio/ref/graphiceq-system-object.html  '];
            s=[s 'The graphicEQ System object? implements a graphic equalizer that can tune the gain on  '];
            s=[s 'individual octave or fractional octave bands. The object filters the data independently  '];
            s=[s 'across each input channel over time using the filter specifications.  '];
            s=[s 'Center and edge frequencies of the bands are based on the ANSI S1.11-2004 standard. '];
            
            obj.descriptor=s;
        end
        
        function display_equalizer(obj)
           if ~isempty(obj.equalizer)
               parameterTuner(obj.equalizer);
           end
        end
        
        function post_init(obj) % called the second times around
            if ~isempty(obj.equalizer)
                release(obj.equalizer)
            end
            
             gains=parse_csv(getvalue(obj.p,'Gains'));
           
            obj.equalizer = graphicEQ('SampleRate',obj.parent.SampleRate,...
                'EQOrder',getvalue(obj.p,'EQOrder'),...
                'Structure',getvalue(obj.p,'Structure'),...
                'Bandwidth',getvalue(obj.p,'Bandwidth'),...
                'Gains',gains);
            
            p=getparameter(obj.p,'change gains');
            p.button_target.equalizer=obj.equalizer;
            
            
            %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
            sync_initializations(obj); % in order to catch potential other modules that need to be updated!
            
        end
        
        function newsig=apply(obj,sig)
            if has_changed(obj.p)
                post_init(obj);
                set_changed_status(obj.p,0);
            end
            newsig =obj.equalizer(sig);
        end
        
        function close(obj)
            if ~isempty(obj.equalizer)
                release(obj.equalizer)
            end
        end
    end
    
end