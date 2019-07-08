%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



classdef caim_strobes
    properties
        threshold_;
        parab_a_;
        parab_b_;
        parab_wnull_;
        parab_var_samples_;
        strobe_count_;
        last_lthresh_;
        samples_since_last_strobe_;
        max_strobe_count;
        strobe_decay_samples;
        parent;
        height_;
        parabw_;
        strobe_decay_time_;
        strobes;
        debug;
        threshsave;
        n=0;
    end
    
    methods
        function obj=caim_strobes(parent)  %init
            obj.parent=parent;
            sr=parent.sample_rate;
            num_channels=parent.num_channels;
            
            centre_frequencies=parent.centre_frequencies;
            obj.max_strobe_count=50;% limit on strobes.
            obj.height_ = 1.2;
            obj.parabw_ = 1.5;
            obj.strobe_decay_time_ = 0.02;
            % Number of samples over which the threshold should decay
            obj.strobe_decay_samples = floor(obj.strobe_decay_time_/sr);
            
            obj.parab_a_=single(zeros(num_channels,1));
            obj.parab_b_=single(zeros(num_channels,1));
            obj.parab_wnull_=single(zeros(num_channels,1));
            obj.parab_var_samples_=int32(zeros(num_channels,1));
            obj.threshold_=single(zeros(num_channels,1));
            obj.last_lthresh_=single(zeros(num_channels,1));
            obj.samples_since_last_strobe_=int32(ones(num_channels,1)*inf);
            
            for ch = 1:num_channels
                obj.parab_wnull_(ch) = obj.parabw_ / centre_frequencies(ch);
                obj.parab_var_samples_(ch) = floor(obj.parab_wnull_(ch) / sr);
                obj.parab_a_(ch) = 4*(1-obj.height_)/(obj.parab_wnull_(ch) * obj.parab_wnull_(ch));
                obj.parab_b_(ch) = -obj.parab_wnull_(ch) / 2;
            end
            obj.debug=0; % show me some info!
            if obj.debug
                obj.threshsave=zeros(256,1);
            end
        end
        
        function obj=step(obj,inp)
            if obj.debug
                obj.n=0;
            end
            
            obj.strobes = int32(zeros(obj.parent.num_channels,obj.max_strobe_count));
            obj.strobe_count_=int32(zeros(obj.parent.num_channels,1));
            sr=obj.parent.sample_rate;
            
            for ch = 1:obj.parent.num_channels
                cur_thresh=obj.threshold_(ch);  % curren threshold
                curr_sample = inp(ch,1);
                next_sample = inp(ch,2);
                strc=obj.strobe_count_(ch);
                thresh_last_strobe=obj.last_lthresh_(ch);
                pvs=obj.parab_var_samples_(ch);
                samples_sincec_last=obj.samples_since_last_strobe_(ch);
                pwn=obj.parab_wnull_(ch);
                pa=obj.parab_a_(ch);
                pb=obj.parab_b_(ch);
                stro=obj.strobes(ch,:);
                
                if obj.debug
                    obj.n=obj.n+1;
                    obj.threshsave=zeros(size(inp));
                    obj.threshsave(obj.n)=cur_thresh;
                end
                
                for ii=2:obj.parent.window_length
                    prev_sample = curr_sample;
                    curr_sample = next_sample;
                    next_sample = inp(ch, ii);
                    
                    if (curr_sample > cur_thresh)
                        cur_thresh = curr_sample;
                        if prev_sample < curr_sample && next_sample < curr_sample
                            % We have a strobe: set threshold and add strobe to the list
                            strc=strc+1;
%                             if strc>obj.max_strobe_count
%                                 continue % ignore!
%                             end
                            stro(strc)= ii-1;
                            thresh_last_strobe = cur_thresh;
                            cur_thresh=cur_thresh*obj.height_;  % throw up the threshold
                            pvs = int32(floor(1/sr*(pwn-(cur_thresh-2*pa*pb)/(2*pa))));
                        end
                    end
                    if (strc > 0)
                        samples_sincec_last = ii-stro(strc);
                    else
                        samples_sincec_last =samples_sincec_last+1;
                    end
                    
                    if (samples_sincec_last > pvs)
                        decay_constant = thresh_last_strobe / obj.strobe_decay_samples;
                        if (cur_thresh > decay_constant)
                            cur_thresh = cur_thresh - decay_constant;
                        else
                            cur_thresh = single(0);
                        end
                    else
                        cur_thresh=thresh_last_strobe*(pa*(single(samples_sincec_last)*sr+pb) ...
                            *(single(samples_sincec_last)*sr+pb)+obj.height_);
                    end
                    
                    
                    if obj.debug
                        obj.n=obj.n+1;
                        obj.threshsave(obj.n)=cur_thresh;
%                         clf
%                         plot(inp)
%                         hold on
%                         plot(obj.threshsave);
%                         strob=zeros(size(inp));
%                         if sum(stro)>0
%                             strob(stro(stro>0))=inp(stro(stro>0));
%                         end
%                         plot(strob,'g');
                    end
                    
                    
                end
                
                obj.strobe_count_(ch)=strc;
                if isinf(cur_thresh)
                    disp('warning: caim_strobes has an infinite threshold, why!?');
                end
%                 if ~isinf(cur_thresh)
%                     obj.threshold_(ch)=cur_thresh;
%                 else
%                     obj.threshold_(ch)=0;
%                 end
                obj.last_lthresh_(ch)=thresh_last_strobe;
                obj.parab_var_samples_(ch)=pvs;
                obj.samples_since_last_strobe_(ch)=samples_sincec_last;
                obj.parab_wnull_(ch)=pwn;
                obj.parab_a_(ch)=pa;
                obj.parab_b_(ch)=pb;
                
                obj.strobes(ch,:)=stro;
             end
        end
    end
end




