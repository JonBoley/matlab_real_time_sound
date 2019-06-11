%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

classdef caim_sai
    
    
    properties
        next_strobes_;
        sai_;
        active_strobes_;
        strobe_weights_;
        decay_factor_;
        max_delay_ms;
        strobe_weight_alpha;
        buffer_memory_decay;
        max_concurrent_strobes;
        sai_window_length;
        max_strobe_delay_idx;
        sai_decay_factor;
        parent;
        buffer;
    end
    
    methods
        function obj=caim_sai(parent)
            
            obj.parent=parent;
            obj.max_delay_ms = 35;
            obj.strobe_weight_alpha = 0.5;
            obj.buffer_memory_decay = 0.03;
            obj.max_concurrent_strobes=20;
            sample_rate=parent.sample_rate;
            
            
            obj.sai_window_length = 1 + floor(1/sample_rate*obj.max_delay_ms/1000);
            obj.max_strobe_delay_idx = int32(floor(1/sample_rate*obj.max_delay_ms/1000));
            obj.sai_decay_factor = power(0.5, 1/(obj.buffer_memory_decay/sample_rate));
            
            obj.active_strobes_.time=int32(zeros(obj.parent.num_channels,obj. max_concurrent_strobes));
            obj.active_strobes_.weight=ones(obj.parent.num_channels, obj.max_concurrent_strobes);
            obj.active_strobes_.wweight=ones(obj.parent.num_channels, obj.max_concurrent_strobes);
            obj.active_strobes_.nr=int32(zeros(obj.parent.num_channels,1));
            obj.sai_=single(zeros(obj.parent.num_channels,obj.sai_window_length));
            obj.strobe_weights_=zeros(obj.max_concurrent_strobes,1);
            for n = 1:obj.max_concurrent_strobes
                obj.strobe_weights_(n) = power(1/(n+1), obj.strobe_weight_alpha);
            end
            %precomputer decay factors
            obj.decay_factor_=zeros(obj.parent.window_length,1);
            for ii=1:obj.parent.window_length
                obj.decay_factor_(ii) = power(obj.sai_decay_factor, obj.parent.window_length-ii);
            end
            

        end
        
        
        function obj=step(obj,strobes,nap)
            
            num_channels=obj.parent.num_channels;
            window_length=obj.parent.window_length;
            sample_rate=obj.parent.sample_rate;
            
            % Offset the times on the strobes from the previous buffer
            for ch = 1:num_channels
                nr=obj.active_strobes_.nr(ch);
                if nr>0
                    obj.active_strobes_.time(ch,1:nr)=obj.active_strobes_.time(ch,1:nr)-window_length;
                end
            end
            
            %Reset the next strobe times
            obj.next_strobes_=int32(ones(num_channels,1));
            
            % temp sai that is produced this round only
            temp_sai=single(zeros(num_channels,obj.sai_window_length));
%             grafix=1;
            
            
            
            % Loop over samples to make the SAI
            % Loop over channels
            for ch=1:num_channels
                
%                 for ch=20
                cstr=strobes(ch,:);
                cstrobes=int32(cstr(cstr>0));
                length_cstrobes=int32(length(cstrobes)); % speed up
                ssig=nap(ch,:);
                
%                     if grafix
%                         figure(23),clf,
%                         subplot(4,1,1), hold on
%                         plot(obj.sai_(ch,:));
%                         title('starting sai')
%                         subplot(4,1,2), hold on
%                         plot(ssig);
%                         plot(cstrobes,ssig(cstrobes),'ro','markerfacecolor','r');
%                         title('frame and strobes')
%                     end
                
                
                % Local convenience variables
                % replace active_strobes with struct
                active_strobes.time=obj.active_strobes_.time(ch,:);
                active_strobes.weight=obj.active_strobes_.weight(ch,:);
                active_strobes.wweight=obj.active_strobes_.wweight(ch,:);
                active_strobes.nr=obj.active_strobes_.nr(ch);
                
                next_strobe_index = obj.next_strobes_(ch);
                temp_sai_c=single(zeros(obj.sai_window_length,1));
                
                for ii=1:window_length
                    % Update strobes
                    % If we are up to or beyond the next strobe...
                    if next_strobe_index <= length_cstrobes
                        if ii == cstrobes(next_strobe_index)
                            % A new strobe has arrived.
                            % If there are too many strobes active, then get rid of the
                            % earliest one
                            if (active_strobes.nr >= obj.max_concurrent_strobes)
                                active_strobes(1:end-1)=active_strobes(2:end);
                                active_strobes.nr=active_strobes.nr-1;
                            end
                            
                            % Add the active strobe to the list of current strobes and
                            % calculate the strobe weight
                            weight = 1;
                            if (active_strobes.nr > 1)
                                last_strobe_time = active_strobes.time(active_strobes.nr-1);
                                
                                % If the strobe occured within 10 impulse-response
                                % cycles of the previous strobe, then lower its weight
                                weight = double(ii - last_strobe_time) / sample_rate ...
                                    * obj.parent.centre_frequencies(ch) / 10 ;
                                if (weight > 1)
                                    weight = 1;
                                end
                            end
                            % add strobe
                            active_strobes.weight(active_strobes.nr+1)=weight;
                            active_strobes.time(active_strobes.nr+1)=ii;
                            active_strobes.nr=active_strobes.nr+1;
                            next_strobe_index=next_strobe_index+1;
                            
                            % Update the strobe weights
                            total_strobe_weight = 0 ;
                            for si = 1:active_strobes.nr
                                total_strobe_weight = active_strobes.weight(si) ...
                                    * obj.strobe_weights_(active_strobes.nr - si + 1);
                            end
                            for si = 1:active_strobes.nr
                                active_strobes.wweight(si)=...
                                    (active_strobes.weight(si) ...
                                    * obj.strobe_weights_(active_strobes.nr - si + 1) ...
                                    / total_strobe_weight);
                            end
                        end
                    end
                    
                    % Remove inactive strobes
                    while (active_strobes.nr > 0)
                        % Get the relative time of the first strobe, and see if it exceeds
                        % the maximum allowed time.
                        if (ii - active_strobes.time(1)) > obj.max_strobe_delay_idx
                            % delete the first strobe
                            nr=active_strobes.nr+1;
                            active_strobes.weight(1:nr-1)=active_strobes.weight(2:nr);
                            active_strobes.time(1:nr-1)=active_strobes.time(2:nr);
                            active_strobes.wweight(1:nr-1)=active_strobes.wweight(2:nr);
                            active_strobes.nr=active_strobes.nr-1;
                        else
                            break;
                        end
                    end
                    % Update the SAI buffer with the weighted effect of all the active
                    % strobes at the current sample
                    for si = 1:active_strobes.nr
                        % Add the effect of active strobe at correct place in the SAI buffer
                        % Calculate 'delay', the time from the strobe event to now
                        delay = ii - active_strobes.time(si);
                        
                        % If the delay is greater than the (user-set)
                        % minimum strobe delay, the strobe can be used
                        if delay>0 && delay < obj.max_strobe_delay_idx
                            % The value at be added to the SAI
                            sigv = ssig(ii);
                            % Weight the sample correctly
                            sigv = sigv * active_strobes.wweight(si);
                            % Adjust the weight acording to the number of samples until the next output frame
                            sigv = sigv* obj.decay_factor_(window_length+1-ii);
                            % Update the temporary SAI buffer
                            temp_sai_c(delay)=temp_sai_c(delay) + sigv;
                        end
                    end
                    
                    
%                             if grafix
%                                 figure(23)
%                                 subplot(4,1,3), hold on
%                                 plot(temp_sai_c)
%                                 title('temp sai')
%                                 drawnow
%                             end
%                     %
%                     figure(1)
                    
                end  % End loop over samples
                
                
                obj.next_strobes_(ch) = next_strobe_index;
                obj.active_strobes_.time(ch,:)=active_strobes.time;
                obj.active_strobes_.weight(ch,:)=active_strobes.weight;
                obj.active_strobes_.wweight(ch,:)=active_strobes.wweight;
                obj.active_strobes_.nr(ch,:)=active_strobes.nr;
                temp_sai(ch,:)=temp_sai_c;
                
                %     figure(2),clf,hold on
                %     plot(temp_sai_c)
                
                
                
            end  % End loop over channels
            
            % one frame is always the length of the frame! NOT the same as in aimc
            
            % Decay the SAI by the correct amount and add the current output frame
            decay = power(obj.sai_decay_factor, window_length);
            sai=obj.sai_.* decay + temp_sai;
            obj.sai_=sai;
            obj.buffer=sai;
        end
    end
end

