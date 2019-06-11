%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function output=aim_sii(inp,simparams)

sample_rate =simparams(1);
num_channels =simparams(2);
lowFreq  =simparams(3);
highFreq  =simparams(4);

num_channels=size(inp,1);
% window_length=size(inp,2);
centre_frequencies=calc_centre_frequencies(num_channels,lowFreq,highFreq);

buffer_length=size(inp,2);

% Cut off the SSI at the end of the first cycle
do_pitch_cutoff_ = false;

% Weight the values in each channel more strongly if the channel was
% truncated due to the pitch cutoff. This ensures that the same amount of
% energy remains in the SSI spectral profile
weight_by_cutoff_ = false;

% Weight the values in each channel more strongly if the channel was
% scaled such that the end goes off the edge of the computed SSI.
% Again, this ensures that the overall energy of the spectral profile
% remains the same.
weight_by_scaling_ = false;

% Time from the zero-lag line of the SAI from which to start searching
% for a maximum in the input SAI's temporal profile.
pitch_search_start_ms_ = 2;

% Total width in cycles of the whole SSI
ssi_width_cycles_ = 10;

% Set to true to make the cycles axis logarithmic (ie indexing by gamma
% rather than by cycles)
log_cycles_axis_ = true;

% The centre frequency of the channel which will just fill the complete
% width of the SSI buffer
pivot_cf_ =1000;

% Whether or not to do smooth offset when the pitch cutoff is active.
do_smooth_offset_ = false;

% The number of cycles, centered on the pitch line, over which the SSI is taken
% to zero when doing the pitch cutoff.
smooth_offset_cycles_ = 3 ;

ssi_width_samples_ = floor(1/sample_rate * ssi_width_cycles_ / pivot_cf_);


output=zeros(num_channels,ssi_width_samples_);

h_=zeros(ssi_width_samples_,1);
gamma_min = -1 ;
gamma_max = log2(ssi_width_cycles_);
for ii = 1:ssi_width_samples_
    if log_cycles_axis_
        gamma = gamma_min + (gamma_max - gamma_min) *ii/ssi_width_samples_;
        h_(ii)= power(2 , gamma);
    else
        h_(ii) = ii * ssi_width_cycles_/ ssi_width_samples_;
    end
end

pitch_index = int32(buffer_length - 1);
if do_pitch_cutoff_
    %     pitch_index = ExtractPitchIndex(input);
    % Generate temporal profile of the SAI
    sai_temporal_profile=single(sum(inp));
    % Find pitch value
    start_sample = floor(pitch_search_start_ms_ * 1/sample_rate / 1000 );
    max_idx = int32(0);
    max_val = single(0) ;
    for ii = start_sample:buffer_length
        if (sai_temporal_profile(ii) > max_val)
            max_idx = int32(ii);
            max_val = sai_temporal_profile(ii);
        end
    end
    pitch_index=max_idx;
end


for ch = 1:num_channels
    centre_frequency = centre_frequencies(ch);
    cycle_samples = 1/sample_rate / centre_frequency;
    
    channel_weight = single(1) ;
    cutoff_index = int32(buffer_length - 1);
    if do_pitch_cutoff_
        if pitch_index < cutoff_index
            if weight_by_cutoff_
                channel_weight = single(buffer_length/ pitch_index);
            end
            cutoff_index = pitch_index;
        end
    end
    
    % tanh(3) is about 0.995. Seems reasonable.
    smooth_pitch_constant = 3/smooth_offset_cycles_;
    pitch_h = 0 ;
    if do_smooth_offset_
        pitch_h = pitch_index/cycle_samples;
    end
    
    % Copy the buffer from input to output, addressing by h-value.
    for ii = 1:ssi_width_samples_
        % The index into the input array is a floating-point number, which is
        % split into a whole part and a fractional part. The whole part and
        % fractional part are found, and are used to linearly interpolate
        % between input samples to yield an output sample.
        sample = floor(h_(ii) * cycle_samples);
        frac_part = h_(ii) * cycle_samples-sample;
        weight = channel_weight;
        
        if do_smooth_offset_ && do_pitch_cutoff_
            % Smoothing around the pitch cutoff line.
            pitch_weight = (1  + tanh((pitch_h - h_(ii)) ...
                * smooth_pitch_constant)) / 2 ;
            weight = weight *pitch_weight;
        end
        
        if weight_by_scaling_
            if centre_frequency > pivot_cf_
                weight =weight *(centre_frequency / pivot_cf_);
            end
        end
        
        if sample < cutoff_index || do_smooth_offset_
            curr_sample = inp(ch, sample);
            next_sample = inp(ch, sample + 1);
            val = weight * (curr_sample ...
                + frac_part * (next_sample - curr_sample));
        else
            val = single(0) ;
        end
        output(ch,ii)=val;
    end
end


