% writes results into a (growing) variable
classdef rt_output_var < rt_output & no_show
    properties
        counter=1;
    end
    
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function obj=rt_output_var(parent,varargin) %% called the very first time around
            obj@rt_output(parent,varargin{:})
            obj.fullname='output into variable';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'variable_name','res');
            parse(pars,varargin{:});
            add(obj.p,param_generic('variable_name',pars.Results.variable_name));
        end
        
        function obj=post_init(obj) % called the second times around
            obj.counter=1;
        end
        
        function write_next(obj,sig)
            varname=getvalue(obj.p,'variable_name');
            v=evalin('base',varname);
            v=[v;sig(:)];
            assignin('base',varname,v);
        end
    end
end
