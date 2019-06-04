


classdef rt_manipulator < rt_module
    properties
    end
    
    methods
        function obj=rt_manipulator(parent,varargin) %% called the very first time around
            obj@rt_module(parent,varargin{:});
            obj.is_manipulation=1;
        end
        
        function post_init(obj)
        end
        
        function sync_initializations(obj)
            % Interrupt for a second! At this stage, it might have
            % happend, that the first module called the post_init
            % routine, because some parameters have changed. Catch
            % this! And call post_init for the second module from
            % here:
            if ~isempty(obj.partner)
                post_init(obj.partner);
            end
        end
        
        
        function sig=apply(obj,sig)
        end
        
    end
    
end

