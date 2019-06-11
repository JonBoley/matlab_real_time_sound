%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% input module, takes a variable and presentes it as input
classdef rt_input_var < rt_input
    properties
        counter;
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_input_var(parent,varargin) %% called the very first time around
            obj@rt_input(parent,varargin{:});
            obj.fullname='passed variable';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'variable',[]);
            parse(pars,varargin{:});           

            add(obj.p,param_generic('variable',pars.Results.variable));
        end
        
        function obj=post_init(obj) % called the second times around
            post_init@rt_input(obj);
            obj.counter=1;
        end
        
        function sig=read_next(obj)
            var=getvalue(obj.p,'variable');
            
            c1=obj.counter;
            c2=c1+obj.parent.frame_length-1;
            if c2>length(var)
                var=[var;zeros(c2-length(var),1)];
            end
            sig=var(c1:c2); 
            obj.counter=c2;
        end
        
        function obj=setvalues(obj,val)
           setvalue(obj.p,'variable',val);
        end
    end
end

