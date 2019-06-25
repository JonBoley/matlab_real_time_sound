%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

function calib=run_output_calibration(bw,filename,calib_level)
if nargin<3
    calib.calib_level=calib_level;
end
if nargin<2
    filename='calib_file.m';
end
if nargin<1
    bw='1 octave';
end

switch bw
    case '1 octave'
        frf=10;
        % case 1 octave
        calib.bandwidth='1 octave';
        calib.preferred_frequencies=[31.5 63 125 250 500 1000 2000 4000 8000 16000];
        calib.gains=zeros(size(calib.preferred_frequencies));
        
    case '2/3 octave'
        frf=15;
        % case 2/3 octave
        calib.bandwidth='2/3 octave';
        calib.preferred_frequencies=[25 40 63 100 160 250 400 630 1000 1600 2500 4000 6300 10000 16000];
        calib.gains=zeros(size(calib.preferred_frequencies));
        
    case '1/3 octave'
        frf=30;
        % case 1/3 octave
        calib.bandwidth='1/3 octave';
        calib.preferred_frequencies=[25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
        calib.gains=zeros(size(calib.preferred_frequencies));
end


pp=parameterbag('calibration');
for i=1:frf
    s=sprintf('%4.1f Hz',calib.preferred_frequencies(i));
    ppp{i}=param_number_with_button(s,calib_level,'button_callback_function',sprintf('play_calibration_sound(%f,%f)',calib.preferred_frequencies(i),calib_level),'button_text','play sound');
    add(pp,ppp{i})
end
% add(pp,param_number('AssumedLoudnessdB',calib_level));
add(pp,param_generic('filename',filename));
add(pp,param_button('finished?','button_callback_function','close(param.parent.guihandle)','button_text','Close!'));

gui(pp,'modal');

% save the file in readable form:
s=[];c=0;
c=c+1;s{c}='% Output calibration for realtime sound platform (github:sbleeck/matlab_real_time_sound)';

if ismac
    [status, fullname] = system('id -F');
    c=c+1;s{c}=sprintf('%% performed by %s',fullname);
else
    c=c+1;s{c}=sprintf('%% performed by %s',getenv('username'));
end

c=c+1;s{c}=sprintf('%% %s',date);

c=c+1;s{c}=sprintf('calib.bandwidth=''%s'';',calib.bandwidth);
sc='[';
sf='[';
for i=1:length(ppp)
    calval=calib_level-getvalue(ppp{i});
    sc=[sc sprintf(' %2.1f',calval)];
    sf=[sf sprintf(' %2.1f',calib.preferred_frequencies(i))];
end
sc=[sc ']'];
sf=[sf ']'];
c=c+1;s{c}=sprintf('calib.preferred_frequencies=%s;',sf);
c=c+1;s{c}=sprintf('calib.gains=%s;',sc);


savetofile(s,getvalue(pp,'filename'));
calib.preferred_frequencies=[25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
calib.gains=zeros(size(calib.preferred_frequencies));
return


