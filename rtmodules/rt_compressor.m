


classdef rt_compressor < rt_manipulator
    properties
        mycompress;
    end
    
    methods
        
        function obj=rt_compressor(parent,varargin)
           obj@rt_manipulator(parent,varargin);  % superclass contructor
            obj.fullname='Compression'; % full name identifies it later on the screen
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'Threshold',-15);
            addParameter(pars,'Ratio',5);
            addParameter(pars,'KneeWidth',10);
            addParameter(pars,'AttackTime',0.05);
            addParameter(pars,'ReleaseTime',0.2);

            parse(pars,varargin{:});           

            add(obj.p,param_float_slider('Threshold',pars.Results.Threshold,'minvalue',-50, 'maxvalue',0));
            add(obj.p,param_float_slider('Ratio',pars.Results.Ratio,'minvalue',1, 'maxvalue',20));
            add(obj.p,param_float_slider('KneeWidth',pars.Results.KneeWidth,'minvalue',0, 'maxvalue',20));
            add(obj.p,param_float_slider('AttackTime',pars.Results.AttackTime,'minvalue',0, 'maxvalue',4,'unittype',unit_time,'unit','sec'));
            add(obj.p,param_float_slider('ReleaseTime',pars.Results.ReleaseTime,'minvalue',0, 'maxvalue',4,'unittype',unit_time,'unit','sec'));
        end
        
        function post_init(obj) % called the second times around
            obj.mycompress = compressor( ...
                'Threshold',getvalue(obj.p,'Threshold'),...
                'KneeWidth',getvalue(obj.p,'KneeWidth'),...
                'Ratio',getvalue(obj.p,'Ratio'),...
                'AttackTime',getvalue(obj.p,'AttackTime'),...
                'ReleaseTime',getvalue(obj.p,'ReleaseTime'),...
                'MakeUpGainMode','auto',...
                'SampleRate',obj.parent.SampleRate);
            

            set_changed_status(obj.p,0);
            
                        %% if overlap and add, there exist another module that needs to be updated too!!
            % make sure that the other module doesn't get forgotton:
             sync_initializations(obj); % in order to catch potential other modules that need to be updated!

        end
        
        function sr=apply(obj,s)
            if has_changed(obj.p)
                obj.mycompress.Threshold=getvalue(obj.p,'Threshold');
                obj.mycompress.Ratio=getvalue(obj.p,'Ratio');
                obj.mycompress.KneeWidth=getvalue(obj.p,'KneeWidth');
                obj.mycompress.AttackTime=getvalue(obj.p,'AttackTime');
                obj.mycompress.ReleaseTime=getvalue(obj.p,'ReleaseTime');
                set_changed_status(obj.p,0);
            end
            
            % we handle the signal in Pascal with a maximum SPL of 100 (set
            % in rtmodule, Compressor handles it in a range from 0 to 1, we
            % need to scale the whole thing down:
            pmax=obj.P0*power(10,obj.MAXVOLUME/20);
            s=s./pmax;
            sr = obj.mycompress(s);
            sr=sr.*pmax;
            
%             figure(3)
%             hold on
%             plot(s)
%             plot(sr,'g')
            
%   Copyright 2019 Stefan Bleeck, University of Southampton
        end
        
        function change_parameter(obj)
            gui(obj.p);
        end
    end
    
end
