

classdef caim_strobes
    properties
        threshold_;
        parab_a_;
        parab_b_;
        parab_wnull_;
        parab_var_samples_;
        strobe_count_;
        last_thresh_;
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
            obj.last_thresh_=single(zeros(num_channels,1));
            obj.samples_since_last_strobe_=int32(ones(num_channels,1)*inf);
            
            for ch = 1:num_channels
                obj.parab_wnull_(ch) = obj.parabw_ / centre_frequencies(ch);
                obj.parab_var_samples_(ch) = floor(obj.parab_wnull_(ch) / sr);
                obj.parab_a_(ch) = 4*(1-obj.height_)/(obj.parab_wnull_(ch) * obj.parab_wnull_(ch));
                obj.parab_b_(ch) = -obj.parab_wnull_(ch) / 2;
            end
            obj.debug=1; % show me some info!
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
                thresh=obj.threshold_(ch);
                curr_sample = inp(ch,1);
                next_sample = inp(ch,2);
                strc=obj.strobe_count_(ch);
                lthresh=obj.last_thresh_(ch);
                pvs=obj.parab_var_samples_(ch);
                ssls=obj.samples_since_last_strobe_(ch);
                pwn=obj.parab_wnull_(ch);
                pa=obj.parab_a_(ch);
                pb=obj.parab_b_(ch);
                stro=obj.strobes(ch,:);
                
                if obj.debug
                    obj.n=obj.n+1;
                    obj.threshsave(obj.n)=thresh;
                end
                
                for ii=2:obj.parent.window_length
                    prev_sample = curr_sample;
                    curr_sample = next_sample;
                    next_sample = inp(ch, ii);
                    
                    if (curr_sample > thresh)
                        thresh = curr_sample;
                        if prev_sample < curr_sample && next_sample < curr_sample
                            % We have a strobe: set threshold and add strobe to the list
                            strc=strc+1;
                            if strc>obj.max_strobe_count
                                continue % ignore!
                            end
                            stro(strc)= ii-1;
                            lthresh = thresh;
                            thresh=thresh*obj.height_;
                            pvs = int32(floor(1/sr*(pwn-(thresh-2*pa*pb)/(2*pa))));
                        end
                    end
                    if (strc > 0)
                        ssls = ii-stro(strc);
                    else
                        ssls =ssls+1;
                    end
                    
                    if (ssls > pvs)
                        decay_constant = lthresh / obj.strobe_decay_samples;
                        if (thresh > decay_constant)
                            thresh = thresh - decay_constant;
                        else
                            thresh = single(0);
                        end
                    else
                        thresh=lthresh*(pa*(single(ssls)*sr+pb) ...
                            *(single(ssls)*sr+pb)+obj.height_);
                    end
                    
                    
                    if obj.debug
                        obj.n=obj.n+1;
                        obj.threshsave(obj.n)=thresh;
                    end
                    
                    
                end
                
                obj.strobe_count_(ch)=strc;
                if ~isinf(thresh)
                    obj.threshold_(ch)=thresh;
                else
                    obj.threshold_(ch)=0;
                end
                obj.last_thresh_(ch)=lthresh;
                obj.parab_var_samples_(ch)=pvs;
                obj.samples_since_last_strobe_(ch)=ssls;
                obj.parab_wnull_(ch)=pwn;
                obj.parab_a_(ch)=pa;
                obj.parab_b_(ch)=pb;
                
                obj.strobes(ch,1:length(stro))=stro;
             end
        end
    end
end



