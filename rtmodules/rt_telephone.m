


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
            
            %             pars = inputParser;
            %             pars.KeepUnmatched=true;
            %             addParameter(pars,'gain',1);
            %             parse(pars,varargin{:});
            %             obj.p=add(obj.p,param_slider('gain',pars.Results.gain,'minvalue',-20, 'maxvalue',20));
            
            
            %
            %             if nargin<2
            %                 name='Telephone';
            %             end
            %
            %             obj@manipulator(parent,name);
            %             obj.parent=parent;
            
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