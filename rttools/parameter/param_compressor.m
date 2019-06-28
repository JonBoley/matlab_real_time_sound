%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

% allows to adjust the knee point, returns threshold and ratio
% internal info: kneepoint (x,y) and maxamp
classdef param_compressor < parameter
    properties (SetAccess = protected)
        myaxis=[];
        mypoint=[];
        maxamplitude;
        ratio;
        thresh;
        makeup;
    end
    
    methods (Access = public)
        
        function param=param_compressor(text,vals,varargin)
            param@parameter(text,vals,varargin{:});
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'maxamplitude',[100 100]);
            parse(pars,varargin{:});
            param.maxamplitude=pars.Results.maxamplitude;
            k=comp2knee(param,vals(1),vals(2));
            [obj.thresh,obj.ratio,obj.makeup]=knee2comp(param,k);
            param.value=[obj.thresh,obj.ratio,obj.makeup];
        end
        
        function size=get_draw_size(param,panel)
            size(1)=150;
            size(2)=100+param.unit_scaley;
        end
        
        % modification of the raw values in order to get the values
        % relevant for the compressor: compressor must be set to auto
        % addparam.myaxisgain. return values are threshold and ratio
        % return [thresh ratio]
        function ret=getvalue(param)  % get the value of this param
            if isempty(param.mypoint)
                ret=param.value;
            else
                k=get(param.mypoint,'Position'); % this is the kneepoint
                [param.thresh,param.ratio,param.makeup]=knee2comp(param,k);
                ret =[param.thresh,param.ratio,param.makeup];
            end
        end
        
        % translates kneepoint data to threshold and ratio
        function [thresh,ratio,makeup]=knee2comp(param,k)
            maxp=param.maxamplitude;
            thresh=-maxp(1)+k(1);
            ratio=-thresh/(maxp(2)-k(2));
            makeup=(k(2)-k(1));
        end
        
        % translates threshold and ratio to kneepoint
        function k=comp2knee(param,thresh,ratio)
            k(1)=param.maxamplitude(2)+thresh;
            k(2)=param.maxamplitude(1)+thresh/ratio;
        end
        
        function setvalue(param,vv)  % get the value of this param, incoming is thesh and ratio
            param.value=vv;
            if ishandle(param.myaxis) 
                kneep=comp2knee(param,vv(1),vv(2));
                x=kneep(1);y=kneep(2);
                maxp=param.maxamplitude;
                cla(param.myaxis);
                lowlim=0; % lowest limit of axis (0 dB)
                line(param.myaxis,[lowlim, maxp(2)],[lowlim,maxp(2)],'color','r'); % default =red
                line(param.myaxis,[lowlim x],[y-x y],'color','b','linewidth',2);
                line(param.myaxis,[x maxp(2)],[y maxp(2)],'color','b','linewidth',2);
                param.mypoint = drawpoint(param.myaxis,'Position',kneep);
                clickCallback=@(src,event)roi_callback_function(param);
                addlistener(param.mypoint,'ROIMoved',clickCallback);set(param.mypoint,'Position',kneep);
            end
            param.is_changed=1;
            end
        end
        
        function draw(param,panel,x,y)
            size=get_draw_size(param,panel);
            x1=x+param.unit_scalex; % left
            y1=y+param.unit_scalex; % top
            w1=size(1);
            h1=size(2)-param.unit_scaley;
            panel.Scrollable='off'; % the drawpoint doesn't work with scrollable in Matlab 2019
            
            param.myaxis=axes(panel,'units','pixel','position',[x1 y1 w1 h1]);
            
            
            lowlim=0; % lowest limit of axis (0 dB)
            maxp=param.maxamplitude; % max loudness allowed (100 dB?)
            d=0;%(maxp(2)-lowlim)/20;
            set(param.myaxis,'xlim',[lowlim-d,maxp(2)+d]);
            set(param.myaxis,'ylim',[lowlim-d,maxp(2)+d]);
            param.myaxis.Title.Interpreter='None';
            param.myaxis.Title.String=param.text;

            % create the kneepoint and update graphics
            v=param.value; % get thresh and ration
            setvalue(param,v); % uodate grapgiccs
        end
        
        
        %% callback is called when any of the points is moved.
        % we are going to use it to iplement it only (for now) a
        % compressor/
        function roi_callback_function(param,evt)
            % adjust all points according to the requirements:
            % linear growth until point 2, then going to top right.
            kneep=get(param.mypoint,'Position'); % old position
            [thresho,slope]=knee2comp(param,kneep);
            
            % restrictions due to the use of the matlab compressor:
            if thresho<-50  % the threshold can only be 50 dB belosw
                thresho=-50;
            end
            if slope<1 %otherwise it would be an expander
                slope=1;
            end
            
            setvalue(param,[thresho,slope]); % and update graphic
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            vv=getvalue(param);
            s = sprintf('''%s'',[%f,%f]',param.text,vv(1),vv(2));
        end
        
    end
end

