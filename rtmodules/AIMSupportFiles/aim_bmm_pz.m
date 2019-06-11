%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function output=aim_bmm_pz(input,simparams)


persistent output_centre_frequency_ agc_epsilons_ agc_state_
persistent state_1_ state_2_ previous_out_ pole_damps_mod_ inputs_
persistent last_input_ agc_gains_ detect_ pole_frequencies_
persistent rmin_ rmax_ xmin_ xmax_ za0_ za1_ za2_
    

% global sample_rate lowFreq highFreq num_channels
sample_rate_ =1/simparams(1);
num_channels =simparams(2);
cf_min_  =simparams(3);
cf_max_  =simparams(4);
buffer_length_=simparams(5);

pole_damping_ = 0.12;
zero_damping_ = 0.2;
zero_factor_ = 1.4;
step_factor_ = 1/3;
bandwidth_over_cf_ = 0.11;
min_bandwidth_hz_ = 27.0;
agc_factor_ = 12.0;

agc_stage_count_=4;
mindamp_ = 0.18;
maxdamp_ = 0.4;



% first run=init
if isempty(output_centre_frequency_)
    
    output_centre_frequency_=zeros(num_channels,1);
    
    % These buffers may be actively modified by the algorithm
    agc_state_=zeros(num_channels,agc_stage_count_);
    
    state_1_=zeros(num_channels,1);
    state_2_=zeros(num_channels,1);
    previous_out_=zeros(num_channels,1);
    pole_damps_mod_=zeros(num_channels,1);
    inputs_=zeros(num_channels,1);
    
    % Init AGC
    %     AGCDampStep();
    % pole_damps_mod_ and agc_state_ are now be initialized
    
    % Modify the pole dampings and AGC state slightly from their values in
    % silence in case the input is abuptly loud.
    for i = 1:num_channels
        pole_damps_mod_(i) = pole_damps_mod_(i) +0.05;
        for j = 1:agc_stage_count_
            agc_state_(i,j) = agc_state_(i,j)+0.05;
        end
        last_input_ = 0.0;
    end
    
    
    parameter_values =[
        % Fit 515 from Dick
        % Final, Nfit = 515, 9-3 parameters, PZFC, cwt 0
        1.72861,   0.00000,   0.00000,  % SumSqrErr =  13622.24
        0.56657,  -0.93911,   0.89163,  % RMSErr    =  3.26610
        0.39469,   0.00000,   0.00000,  % MeanErr   =  0.00000
        % Inf,       0.00000,   0.00000,  % RMSCost   =  NaN - would set coefc to infinity, but this isn't passed on
        0.00000,   0.00000,   0.00000,
        2.00000,   0.00000,   0.00000,  %
        1.27393,   0.00000,   0.00000,
        11.46247,  5.46894,   0.11800];
    % -4.15525,  1.54874,   2.99858   % Kv
    
    
    % Precalculate the number of channels required - this method is ugly but it
    % was the quickest way of converting from MATLAB as the step factor between
    % channels can vary quadratically with pole frequency...
    
    % Normalised maximum pole frequency
    pole_frequency = cf_max_ / sample_rate_ * (2*pi);
    
    numchan = 0;
    while ((pole_frequency / (2*pi)) * sample_rate_ > cf_min_)
        frequency = pole_frequency / (2*pi) * sample_rate_;
        f_dep = Freq2ERB(frequency)/Freq2ERB(1000) - 1;
        [~,bw] = Freq2ERB(pole_frequency/ (2*pi) * sample_rate_);
        step_factor = 1/ (parameter_values(4*3+1) + parameter_values(4 * 3 + 2)...
            * f_dep + parameter_values(4 * 3 + 3) * f_dep * f_dep);  % 1/n2
        pole_frequency = pole_frequency - step_factor * (bw * (2 * pi) / sample_rate_);
        numchan=numchan+1;
    end
    
    % Now the number of channels is known, various buffers for the filterbank
    % coefficients can be initialised
    pole_dampings_=zeros(num_channels,1);
    pole_frequencies_=zeros(num_channels,1);
    
    % Direct-form coefficients
    za0_=zeros(num_channels,1);
    za1_=zeros(num_channels,1);
    za2_=zeros(num_channels,1);
    
    % Reset the pole frequency to maximum
    pole_frequency = cf_max_ / sample_rate_ * (2*pi);
    
    for i = num_channels:-1:1
        % Store the normalised pole frequncy
        pole_frequencies_(i) = pole_frequency;
        
        % Calculate the real pole frequency from the normalised pole frequency
        frequency = pole_frequency / (2*pi) * sample_rate_;
        
        % Store the real pole frequency as the 'centre frequency' of the filterbank
        % channel
        output_centre_frequency_(i)=frequency; %
        
        % From PZFC_Small_Signal_Params.m   From PZFC_Params.m
        DpndF = Freq2ERB(frequency)/ Freq2ERB(1000) - 1;
        
        %     float p[8];  % Parameters (short name for ease of reading)
        
        % Use parameter_values to recover the parameter values for this frequency
        for param = 0:6
            p(param+1) = parameter_values(param * 3+1) ...
                + parameter_values(param * 3 + 2) * DpndF ...
                + parameter_values(param * 3 + 3) * DpndF * DpndF;
        end
        % Calculate the final parameter
        p(8) = p(2) * power(10, (p(3) / (p(2) * p(5))) * (p(7) - 60) / 20);
        if p(8) < 0.2
            p(8) = 0.2;
        end
        
        % Nominal bandwidth at this frequency
        [~,fERBw]= Freq2ERB(frequency);
        
        % Pole bandwidth
        fPBW = ((p(8) * fERBw * (2 * pi) / sample_rate_) / 2) ...
            * power(p(5), 0.5);
        
        % Pole damping
        pole_damping = fPBW / sqrt(power(pole_frequency, 2) + power(fPBW, 2));
        
        % Store the pole damping
        pole_dampings_(i) = pole_damping;
        
        % Zero bandwidth
        fZBW = ((p(1) * p(6) * fERBw * (2 * pi) / sample_rate_) / 2) ...
            * power(p(5), 0.5);
        
        % Zero frequency
        zero_frequency = p(6) * pole_frequency;
        
        
        % Zero damping
        fZDamp = fZBW / sqrt(power(zero_frequency, 2) + power(fZBW, 2));
        
        % Impulse-invariance mapping
        fZTheta = zero_frequency * sqrt(1.0 - power(fZDamp, 2));
        fZRho = exp(-fZDamp * zero_frequency);
        
        % Direct-form coefficients
        fA1 = -2.0 * fZRho * cos(fZTheta);
        fA2 = fZRho * fZRho;
        
        % Normalised to unity gain at DC
        fASum = 1 + fA1 + fA2;
        za0_(i) = 1 / fASum;
        za1_(i) = fA1 / fASum;
        za2_(i) = fA2 / fASum;
        
        % Subtract step factor (1/n2) times current bandwidth from the pole
        % frequency
        pole_frequency = pole_frequency - ((1 / p(5)) ...
            * (fERBw * (2 * pi) / sample_rate_));
        
    end
    
    rmin_=zeros(num_channels,1);
    rmax_=zeros(num_channels,1);
    xmin_=zeros(num_channels,1);
    xmax_=zeros(num_channels,1);
    
    for c = 1:num_channels
        % Calculate maximum and minimum damping options
        rmin_(c) = exp(-mindamp_ * pole_frequencies_(c));
        rmax_(c) = exp(-maxdamp_ * pole_frequencies_(c));
        
        xmin_(c) = rmin_(c) * cos(pole_frequencies_(c) ...
            * power((1-power(mindamp_, 2)), 0.5));
        xmax_(c) = rmax_(c) * cos(pole_frequencies_(c) ...
            * power((1-power(maxdamp_, 2)), 0.5));
    end
    
    % Set up AGC parameters
    agc_stage_count_ = 4;
    agc_epsilons_(1) = 0.0064;
    agc_epsilons_(2) = 0.0016;
    agc_epsilons_(3) = 0.0004;
    agc_epsilons_(4) = 0.0001;
    
    agc_gains_(1) = 1.0;
    agc_gains_(2) = 1.4;
    agc_gains_(3) = 2.0;
    agc_gains_(4) = 2.8;
    
    mean_agc_gain = 0;
    for c = 1:agc_stage_count_
        mean_agc_gain = mean_agc_gain +agc_gains_(c);
        mean_agc_gain = mean_agc_gain / agc_stage_count_;
    end
    for c = 1:agc_stage_count_
        agc_gains_(c) = agc_gains_(c)/mean_agc_gain;
    end
    
    
end % initialization


%     void ModulePZFC::Process(const SignalBank& input)

for s = 1:buffer_length_
    input_sample = input(s);
    
    % Lowpass filter the input with a zero at PI
    input_sample = 0.5 * input_sample + 0.5 * last_input_;
    last_input_ = input(s);
    
    inputs_(num_channels) = input_sample;
    for c = 1:num_channels-1
        inputs_(c) = previous_out_(c + 1);
    end
    % PZBankStep2
    % to save a bunch of divides
    damp_rate = 1/(maxdamp_ - mindamp_);
    
    for c = num_channels:-1:1
        interp_factor = (pole_damps_mod_(c) - mindamp_) * damp_rate;
        
        x = xmin_(c) + (xmax_(c) - xmin_(c)) * interp_factor;
        r = rmin_(c) + (rmax_(c) - rmin_(c)) * interp_factor;
        
        % optional improvement to constellation adds a bit to r
        fd = pole_frequencies_(c) * pole_damps_mod_(c);
        % quadratic for small values, then linear
        r = r + 0.25 * fd * min(0.05, fd);
        
        zb1 = -2.0 * x;
        zb2 = r * r;
        
        % canonic poles but with input provided where unity DC gain is assured
        % (mean value of state is always equal to mean value of input)
        new_state = inputs_(c) - (state_1_(c) - inputs_(c)) * zb1 - (state_2_(c) - inputs_(c)) * zb2;
        
        % canonic zeros part as before:
        output = za0_(c) * new_state + za1_(c) * state_1_(c)+ za2_(c) * state_2_(c);
        
        % cubic compression nonlinearity
        output = output - 0.0001 * power(output, 3);
        
        output_(c, s)=output;
        %
        output=max(0,output);
        fDetect = min(1, output);
        detect_(c)=0.25 * output + (1 - 0.25) * (fDetect - power(fDetect, 3) / 3);
        
        state_2_(c) = state_1_(c);
        state_1_(c) = new_state;
    end
    
    %     AGCDampStep();
    
    for c = 1:num_channels
        previous_out_(c) = output_(c,s);
    end
end

output=real(output_);


%
%     function f=DetectFun(fIN)
%         fIN=max(0,fIN);
%         fDetect = min(1, fIN);
%         f=0.25 * fIN + (1 - 0.25) * (fDetect - power(fDetect, 3) / 3);
%     end







%
%
%     function AGCDampStep()
%         if (detect_.size() == 0)
%             % If  detect_ is not initialised, it means that the AGC is not set up.
%             % Set up now.
%             /*! \todo Make a separate InitAGC function which does this.
%             */
%             detect_.clear();
%             float detect_zero = DetectFun(0.0f);
%             detect_.resize(num_channels, detect_zero);
%
%             for (int c = 0; c < num_channels; c++)
%                 for (int st = 0; st < agc_stage_count_; st++)
%                     agc_state_(c)[st] = (1.2f * detect_(c) * agc_gains_[st]);
%                 end
%
%                 float fAGCEpsLeft = 0.3f;
%                 float fAGCEpsRight = 0.3f;
%
%                 for (int c = num_channels - 1; c > -1; --c)
%                     for (int st = 0; st < agc_stage_count_; ++st)
%                         % This bounds checking is ugly and wasteful, and in an inner loop.
%                         % If this algorithm is slow, this is why!
%                         /*! \todo Proper non-ugly bounds checking in AGCDampStep()
%                         */
%                         float fPrevAGCState;
%                         float fCurrAGCState;
%                         float fNextAGCState;
%
%                         if (c < num_channels - 1)
%                             fPrevAGCState = agc_state_[c + 1][st];
%                         else
%                             fPrevAGCState = agc_state_(c)[st];
%
%                             fCurrAGCState = agc_state_(c)[st];
%
%                             if (c > 0)
%                                 fNextAGCState = agc_state_[c - 1][st];
%                             else
%                                 fNextAGCState = agc_state_(c)[st];
%
%                                 % Spatial smoothing
%                                 /*! \todo Something odd is going on here
%                                 *  I think this line is not quite right.
%                                 */
%                                 float agc_avg = fAGCEpsLeft * fPrevAGCState
%                                 + (1.0f - fAGCEpsLeft - fAGCEpsRight) * fCurrAGCState
%                                 + fAGCEpsRight * fNextAGCState;
%                                 % Temporal smoothing
%                                 agc_state_(c)[st] = agc_avg * (1.0f - agc_epsilons_[st])
%                                 + agc_epsilons_[st] * detect_(c) * agc_gains_[st];
%                             end
%                         end
%
%                         float offset = 1.0f - agc_factor_ * DetectFun(0.0f);
%
%                         for (int i = 0; i < num_channels; ++i)
%                             float fAGCStateMean = 0.0f;
%                             for (int j = 0; j < agc_stage_count_; ++j)
%                                 fAGCStateMean += agc_state_(i)(j);
%
%                                 fAGCStateMean /= static_cast<float>(agc_stage_count_);
%
%                                 pole_damps_mod_(i) = pole_dampings_(i) *
%                                 (offset + agc_factor_ * fAGCStateMean);
%                             end
%                         end
