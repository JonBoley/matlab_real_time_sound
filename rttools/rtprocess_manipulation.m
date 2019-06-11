%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



% class that deals with rt modules. rt processes can do all that modules
% can, but also for n channels and overlap and add/

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef rtprocess_manipulation < rtprocess
    properties
        win; % hamming window for overlap and add
        lastsig; % every run switch over the manipulators
        w2;
        w2b; % every run switch over the manipulators
    end
    
    methods
        %% called the first time around to create a process from a modules
        function obj=rtprocess_manipulation(parent,mod)
            obj@rtprocess(parent,mod);
            % a process can only be one of the following
            obj.is_manipulation=1;
            
        end
        
        function obj=initialize(obj)
            input_chan=obj.parent.Channels;
%             input_chan=max(chan(1),chan(2));  %todo: make this nicer. at this stage i don't know if there are several input OR output channels. both require selveal modules
            ooo=obj.basic_module;
            for i=1:input_chan
                if obj.parent.OverlapAdd  % create two modules:
                    o1{i}=copy(ooo);
                    o2{i}=copy(ooo);
                    o1{i}.label=sprintf('first module in overlap and add, channel %d',i);
                    o2{i}.label=sprintf('second module in overlap and add, channel %d',i);
                    o1{i}.partner=o2{i};
                    post_init(o1{i});
                    post_init(o2{i})
                    obj.modules{i,1}=o1{i};
                    o1{i}.channel_nr=1; % remember that I am channel 1 (left)
                    obj.modules{i,2}=o2{i};
                    o2{i}.channel_nr=2;% remember that I am channel 2 (right)
                else
                    o{i}=copy(ooo);
                    post_init(o{i});
                    obj.modules{i}=o{i};
                    obj.modules{i}.channel_nr=i;
                end
                
                obj.w2{i}=zeros(obj.parent.FrameLength,1); % setup for first run
                obj.w2b{i}=zeros(obj.parent.FrameLength,1); % setup for first run
                obj.lastsig{i}=zeros(obj.parent.FrameLength,1); % setup for first run
            end
            obj.win=hamming(obj.parent.FrameLength);
        end
        
        function process(obj)
            
            input_chan=obj.parent.Channels;
%             input_chan=chan(1);
            for i=1:input_chan
                %             switch chan
                %                 case 'mono'
                %                     nr_chan=1;
                sig{i}=obj.parent.current_stim(:,i);
                
                %                 case 'stereo'
                %                     nr_chan=2;
                %                     sig{1}=obj.parent.current_stim(:,1);
                %                     sig{2}=obj.parent.current_stim(:,2);
            end
            
            for i=1:input_chan
                if obj.parent.OverlapAdd
                    [sig1,sig2]=split_signal_oad(obj,sig{i},i);
                    sig1=apply(obj.modules{i,1},sig1);
                    sig2=apply(obj.modules{i,2},sig2);
                    sig{i}=unsplit_signal_oad(obj,sig1,sig2,i);
                else
                    sig{i}=apply(obj.modules{i},sig{i});
                end
                
            end
            if input_chan==1
                obj.parent.current_stim=sig{1};
            elseif input_chan==2
                obj.parent.current_stim=[sig{1} sig{2}];
                
            end
            %             if input_chan==1
            %                 obj.parent.current_stim=sig{1};
            %             else
            %                 obj.parent.current_stim=[sig{1} sig{2}];
            %             end
        end
        
        function close(obj)
            %             chan=obj.parent.Channels;
            %             switch chan
            %                 case 'mono'
            %                     nr_chan=1;
            %                 case 'stereo'
            %                     nr_chan=2;
            %             end
            for i=1:length(obj.modules)
                
                close(obj.modules{i});
                
                
                %                 if length(obj.modules)==1
                %                     close(obj.modules{1});
                %                 else
                %                     close(obj.modules{1});
                %                     close(obj.modules{2});
                %                 end
                
            end
        end
        
        %% function that creates the two signals required for overlap and add
        function [sig1,sig2]=split_signal_oad(obj,sig,nrchan)
            % how does it work?
            % effectively two parallel stimuli streams are processed with two different
            % manipulation objects. each is then windowed with a hanning window
            % overlapping.
            
            nr=length(sig)/2;
            sig1=sig;
            sig2=[obj.lastsig{nrchan}(nr+1:end);sig(1:nr)];
            obj.lastsig{nrchan}=sig;
        end
        
        function rsig=unsplit_signal_oad(obj,sig1,sig2,nrchan)
            sig1=sig1(:);
            sig2=sig2(:);
            
            w1b=sig2.*obj.win; % both are windowed with a hamming window
            w1=sig1.*obj.win;
            
            % build up the last buffer from overlapping windows
            nr=length(sig1)/2;first=1:nr;second=nr+1:length(w1);
            rsig=obj.w2{nrchan};
            rsig(first)=rsig(first)+obj.w2b{nrchan}(second);
            rsig(second)=rsig(second)+w1b(first);
            obj.w2{nrchan}=w1; % save for next round
            obj.w2b{nrchan}=w1b; % save for next round
        end
    end
end




