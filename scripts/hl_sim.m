
function xnew=hl_sim(x,fs,hl)
if nargin<3
       % 25    32    40    50    63    79    100    126    158    200    250    316    398    501    631    794    1000    1259    1585    1995    2512    3162    3981    05012    6310    7943    10000    12589    15849    19953  
 gains='  0,    0,    0,    0,    0,    0,     0,     0,     0,     0,   -10,   -10,   -10,   -10,   -10,   -10,    -20,    -20,    -20,    -20,    -20,    -20,    -30,     -30,    -30,    -30,     -40,     -40,     -40,     -50';
end
if nargin <2
    fs=44100;
end
if nargin<1
    filename='./randomwavs/BKBE0603.WAV';
    [x,fs]=audioread(filename);
end

nrchan=1;
nrsamp=length(x);
dur=nrsamp/fs;

mymodel=rt_model('SampleRate',fs,'FrameLength',nrsamp,'Channels',nrchan,'Duration',dur,'OverlapAdd',0,'PlotWidth',1.000000);
% module_1=rt_input_file(mymodel,'filename',filename,'MaxFileLeveldB',100.000000);
module_1=rt_input_var(mymodel,'variable',x);
add_module(mymodel,module_1);
module_2=rt_graficequal(mymodel,'Bandwidth','1/3 octave','Gains',gains);
add_module(mymodel,module_2);
gui(mymodel);

initialize(mymodel);
run_once(mymodel);
close(mymodel);
xnew=mymodel.current_stim;
