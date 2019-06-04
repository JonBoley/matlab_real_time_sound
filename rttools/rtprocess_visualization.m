
classdef rtprocess_visualization < rtprocess
    properties
    end
    
    methods
        %% called the first time around to create a process from a modules
        function obj=rtprocess_visualization(parent,mod)
            obj@rtprocess(parent,mod);
            % a process can only be one of the following
            
            obj.is_visualization=1;
            
        end
        
        function obj=initialize(obj)
            mypanel=obj.viz_panel;
            chan=obj.parent.Channels;
            %TODO: iterate for more than 2 channels
            switch chan
                case 1
                    % create a visualization
                    obj.basic_module.viz_panel = mypanel;
                    post_init(obj.basic_module);
                    obj.modules{1}=obj.basic_module;
                    obj.modules{1}.channel_nr=1;
                case 2
                    o1=obj.basic_module;
                    o2=copy(o1);
                    
                    if ~isempty(mypanel)  % if isempty, we don't want to see the output
                        x1=1;
                        y1=1;
                        axsize=mypanel.Position;
                        w1=axsize(3)-1;
                        h1=axsize(4)/2-10;
                        x2=1;
                        y2=axsize(4)/2-10;
                        w2=axsize(3)-1;
                        h2=axsize(4)/2-10;
                        o1.viz_panel = uipanel(mypanel,'Position',[x1 y1,w1,h1]); % first axis half size
                        o2.viz_panel = uipanel(mypanel,'Position',[x2 y2,w2,h2]); % second axis half size
                    end
                    obj.modules=[];
                    post_init(o1);
                    post_init(o2);
                    obj.modules{1}=o1;
                    obj.modules{2}=o2;
                    o1.channel_nr=1;
                    o2.channel_nr=2;
                    
            end
        end
        
        function process(obj)
            sig=obj.parent.current_stim;
            for i=1:obj.parent.Channels % input channels
                plot(obj.modules{i},sig);
                %             switch obj.parent.Channels
                %                 case 'mono'
                %                     plot(obj.modules,sig);
                %                 case 'stereo'
                %                     plot(obj.modules{1},sig(:,1));
                %                     plot(obj.modules{2},sig(:,2));
            end
            
            
            function close(obj)
                if obj.basic_module.is_visualization
                    for ii=1:obj.parent.Channels % input channels
                        close(obj.modules{ii});
                        %                     channels=obj.parent.Channels; % how many chanels do we need?
                        %                     switch channels
                        %                         case 'mono'
                        %                             close(obj.modules);
                        %                         case 'stereo'
                        %                             close(obj.modules{1});
                        %                             close(obj.modules{2});
                    end
                end
            end
        end
    end
end



