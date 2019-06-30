%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% script to test any or all of the parameter classes

clear all;
close all force
clc
clear classes;

addpath(genpath('../parameter'));


c=0;
c=c+1;p{c}=param_compressor('0 param_compressor',[-50,1],'maxamplitude',[100 100]);
c=c+1;p{c}=param_generic('1 parameter_generic','123');
c=c+1;p{c}=param_audiogram('Audiogram',[250,0.0; 500,10.0;1000,20.0;2000,30.0;4000,40.0]);
c=c+1;p{c}=param_generic('1 parameter_generic','123');
c=c+1;p{c}=param_checkbox('2 param_checkbox',1);
c=c+1;p{c}=param_checkbox_with_button('3 param_checkbox_with_button',1,'button_callback_function','calback from checkbox','button_text','example');
c=c+1;p{c}=param_twonumbers('4 param_twonumbers',[1,2]);
c=c+1;p{c}=param_number('5 param_number',1345);
c=c+1;p{c}=param_float('6 param_float with unit',2,'unittype',unit_time,'unit','min');
c=c+1;p{c}=param_float('7 param_float',123);
c=c+1;p{c}=param_popupmenu('8 param_popupmenu','first value','list',{'first value';'werwer';'sdfsdfsdf'});

% % add(p,param_filename('9 param_filename','noch nix.wav'));
% % add(p,param_foldername('10 param_foldername','./'));
% % add(p,param_float_slider('11 param_float_slider',2,'unittype',unit_time,'unit','sec','minvalue',-10,'maxvalue',10));
% % add(p,param_slider('12 param_slider',2,'minvalue',-10,'maxvalue',10));
% % add(p,param_button('13 param_button','button_callback_function','calback from buton','button_text','text buu','target',p));
% % add(p,param_number_with_text('14 param_number_with_text',{2342,'any text'}));
% % add(p,param_mouse_panel('15 param_mouse_panel',[0 0;40 50;110 110],'compressor'));
% % add(p,param_mouse_panel('16 param_mouse_panel2',[0 0;50 70;110 110]));
% % add(p,param_popupmenu_with_button('17 param_popupmenu_with_button','second','list',{'first';'second';'sdfsdfsdf'},'button_callback_function','calback from popup','button_text','example button'));
% % add(p,param_switch_with_light('18 param_switch_with_light',1));

for i=1:c
    test(p{i});
end
return 

function test(p)
pb=parameterbag('my test params');
add(pb,p);
h=gui(pb);

val=getvalue(p);
setvalue(p,val);
val2=getvalue(p);
m=metaclass(p);
if isequal(val,val2)
    fprintf('%s is fine\n',m.Name);
else 
    error
end
close(h)
end

% 
% 
% % add(p,
% % add(p,param_generic('1 parameter_generic','123'));
% % add(p,param_audiogram('Audiogram',[0,10,10,20,40],'frequencies',[250,500,1000,2000,4000]));
% % 
% % add(p,param_generic('1 parameter_generic','123'));
% % add(p,param_checkbox('2 param_checkbox',1));
% % add(p,param_checkbox_with_button('3 param_checkbox_with_button',1,'button_callback_function','calback from checkbox','button_text','example'));
% % add(p,param_twonumbers('4 param_twonumbers',[1,2]));
% % add(p,param_number('5 param_number',1345));
% % add(p,param_float('6 param_float with unit',2,'unittype',unit_time,'unit','min'));
% % add(p,param_float('7 param_float',123));
% % add(p,param_popupmenu('8 param_popupmenu','first value','list',{'first value';'werwer';'sdfsdfsdf'}));
% % add(p,param_filename('9 param_filename','noch nix.wav'));
% % add(p,param_foldername('10 param_foldername','./'));
% % add(p,param_float_slider('11 param_float_slider',2,'unittype',unit_time,'unit','sec','minvalue',-10,'maxvalue',10));
% % add(p,param_slider('12 param_slider',2,'minvalue',-10,'maxvalue',10));
% % add(p,param_button('13 param_button','button_callback_function','calback from buton','button_text','text buu','target',p));
% % add(p,param_number_with_text('14 param_number_with_text',{2342,'any text'}));
% % add(p,param_mouse_panel('15 param_mouse_panel',[0 0;40 50;110 110],'compressor'));
% % add(p,param_mouse_panel('16 param_mouse_panel2',[0 0;50 70;110 110]));
% % add(p,param_popupmenu_with_button('17 param_popupmenu_with_button','second','list',{'first';'second';'sdfsdfsdf'},'button_callback_function','calback from popup','button_text','example button'));
% % add(p,param_switch_with_light('18 param_switch_with_light',1));
% 
% % 
% % add(p,p1);
% % add(p,p2);
% % add(p,p2a);
% % add(p,p3);
% % add(p,p4);
% % add(p,p5);
% % add(p,p6);
% % add(p,p7);
% % add(p,p8);
% % add(p,p9);
% % add(p,p10);
% % add(p,p11);
% % add(p,p11);
% % add(p,p13);
% % add(p,p14);
% % add(p,p12);
% % add(p,p15);
% 
% disp(p)
% disp('.');
% disp('.');
% 
% m=p.items;
% k=keys(m);
% for i=1:m.Count
%     s=get_value_string(m(k{i}))
% end
% 
% 
% % add(p,p12);
% % return
% 
% 
% % 
% 
% % setvalue(p,'value 2',1000,'Hz');
% % pi2=setunit(pi2,'msec');
% % disp(p);
% 
% gui(p);
% 
% % 
% % 
% % 
% % getvalue(p,'val 1')
% % getvalue(p,'value 2','sec')
% % getvalue(p,'value 3')
% % 
% % getvalue(p,'value 4')
% % 
% % getvalue(p,'value 5')
% % getvalue(p,'value 6')
% % 
% % getvalue(p,'filename')
