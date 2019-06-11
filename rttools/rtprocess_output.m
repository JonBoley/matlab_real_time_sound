%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% class that deals with rt modules. rt processes can do all that modules
% can, but also for n channels and overlap and add/

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef rtprocess_output < rtprocess
    properties
    end
    
    methods
        %% called the first time around to create a process from a modules
        function obj=rtprocess_output(parent,mod)
            obj@rtprocess(parent,mod);
                    % a process can only be one of the following
        obj.is_output=1;
        end
         
        function obj=process(obj)
            
                write_next(obj.basic_module,obj.parent.current_stim);
            
        end        
    end
end

