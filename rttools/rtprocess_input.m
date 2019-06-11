%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% class that deals with rt modules. rt processes can do all that modules
% can, but also for n channels and overlap and add/

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef rtprocess_input < rtprocess
    properties
        
    end
    
    methods
        %% called the first time around to create a process from a modules
        function obj=rtprocess_input(parent,mod)
            obj@rtprocess(parent,mod);
            % a process can only be one of the following
            obj.is_input=1;
            
        end
        
        function process(obj)
            
            sig=read_next(obj.basic_module);
            channels=obj.parent.Channels; % how many chanels do we need?
            %                 for i=1:channels
            
            nr_col=size(sig,2);  % how many columns did we read in?
            switch channels
                case 1
                    if nr_col==1  % all good
                    elseif nr_col==2
                        sig=sig(:,1); % only take the left channel
                    end
                case 2
                    if nr_col==2  % all good
                    elseif nr_col==1
                        sig=[sig sig]; % double the single channel
                    end
            end
            obj.parent.current_stim=sig;  % return the clean stimulus

        end
    end
end
