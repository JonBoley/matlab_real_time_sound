% takes input of audio from the microphone and plots live roughness levels
% expects microphone gain to be set such that samples are in pascals. 

%initialise listener
Fs = 44100;
micReader = audioDeviceReader('SamplesPerFrame',8192,'SampleRate',Fs);
figure(1)
hold off
i = 1;
dur = 30; % seconds length
t = nan(round((dur+1)*Fs/8192),1); % preallocate time array 1 second longer
R = nan(round((dur+1)*Fs/8192),1); %    than the record length
S = nan(round((dur+1)*Fs/8192),1); % Also store roughness and SPL;

subplot(2,1,1)
plot(0,0); %dummy plot
xlabel('Time (s)')
ylabel('Roughness (Asper)')
ylim([0,2])
hold on
subplot(2,1,2)
plot(0,0)
xlabel('Time(s)')
ylabel('SPL (dB)')
hold on
tic; % start the clock
while(toc<30) 
    audio = micReader(); % grab a frame
    t(i) = toc(); % get current time
    out = roughext(audio,Fs); % calculate roughness with frame
    R(i) = out{1}; % extract roughness from cell array
    S(i) = out{3}; % extract SPL 
    subplot(2,1,1)
    plot(t,R,'k-');
    k = gca;
    subplot(2,1,2)
    plot(t,S,'k-');
    j = gca;
    if t(i)>5
        xlim([t(i)-5,t(i)])
    else
        xlim([0,5])
    end
    linkaxes([k,j],'x')
    drawnow()
    i = i + 1;
end

xlim([0,dur])

