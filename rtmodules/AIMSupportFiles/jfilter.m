%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function [output synthesizer]= jfilter(input,fs)

lower_cutoff_frequency_hz = 100;%70;
upper_cutoff_frequency_hz = 8000;%6700;
base_frequency_hz = 1000; %not sure what this is...
sampling_rate_hz = fs;%16276;%
filters_per_ERB = 1.0;
desired_delay_in_seconds = 0.004;

%% make filterbank with desired parameters
analyzer = Gfb_Analyzer_new(sampling_rate_hz, lower_cutoff_frequency_hz, ...
                               base_frequency_hz, upper_cutoff_frequency_hz,...
                               filters_per_ERB);
%% make synthesize for filterbank

synthesizer = Gfb_Synthesizer_new(analyzer, desired_delay_in_seconds);

% impulse = [1, zeros(1,8191)];                                          
%% Now filter the signal
[analyzed_input, analyzer] = Gfb_Analyzer_process(analyzer, input);
% [resynthesized_impulse, synthesizer] = ...
%     Gfb_Synthesizer_process(synthesizer, analyzed_impulse);
%% now correct for the delay
[output, synthesizer.delay] = Gfb_Delay_process(synthesizer.delay, analyzed_input);
%% this bit corrects for gain (don't need to do this until resynthesis I think) to give flat freq response
% Now I think I do need to do it...
output=repmat(synthesizer.mixer.gains,length(input),1)'.*output;
end
