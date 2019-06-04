


classdef rt_amplify < rt_manipulator
    properties
        gain;
    end
    
    methods
        
        function obj=rt_amplify(parent,varargin)
            obj@rt_manipulator(parent,varargin);
            obj.fullname='Amplification';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'gain',1);
            parse(pars,varargin{:});
            add(obj.p,param_slider('gain',pars.Results.gain,'minvalue',-20, 'maxvalue',20));
            
        end
        
        
        function sr=apply(obj,s)
            obj.gain=getvalue(obj.p,'gain');
            sr=s*power(10,obj.gain/20);
        end
        
    end
    
end