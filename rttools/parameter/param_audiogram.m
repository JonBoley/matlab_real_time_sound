%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


% audiogram x-values: 250, 500, 1000, 2000, 4000
% y-values: -10:60

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef param_audiogram < parameter
    properties (SetAccess = protected)
        mypolyline;
        myaxes;
        my_frequencies;  %frequencies 
    end
    
    methods (Access = public)
        
        function param=param_audiogram(text,vals,varargin)
            param@parameter(text,vals,varargin{:});
            param.value=vals;            
                
             pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'frequencies',[250,500,1000,2000,4000,6000]);
            parse(pars,varargin{:});
           
            param.my_frequencies=pars.Results.frequencies;           
            
            
        end
        
        function size=get_draw_size(param,panel)
            size(1)=400;
            size(2)=250+1*param.unit_scaley;
        end
        
        function vv=getvalue(param)  % get the value of this param
            if isempty(param.mypolyline)
                vv=param.value;
            else
                vv=get(param.mypolyline,'Position');
                param.value=vv;
            end
        end
        
        function setvalue(param,vv)  % get the value of this param
            param.value=vv;
            set(param.mypolyline,'Position',vv);
        end
        
        function draw(param,panel,x,y)
            
            panel.Scrollable='off';
            size=get_draw_size(param,panel);
            [elem1,elem2]=getelementpositions(param,panel,x,y);
            
            up=axes(panel,'units','pixel','position',[elem1.x elem1.y size(1) size(2)-50]);
            
            vv=getvalue(param);
            f=param.my_frequencies;
            
            set(up,'xlim',[0.5 length(f)+0.5]);
            set(up,'ylim',[-10 100]);
            set(up,'YDir','reverse');
            set(up,'xtick',1:length(f));
            set(up,'xticklabel',f);
            set(up,'ytick',[0,20,40,60,80]);
            set(up,'yticklabel',[0,20,40,60,80]);
            thresh=getvalue(param);
            t=matlab.graphics.primitive.Text;
            t.String=param.text;
            set(up,'title',t);
            x=1:length(f);
            y=thresh;
            line(up,[0.5 length(f)+0.5],[0  0],'color','b');
            param.mypolyline = drawpolyline(up,'Position',[x;y]');
            clickCallback=@(src,event)roi_callback_function(param);
            l = addlistener(param.mypolyline,'ROIMoved',clickCallback);
            param.myaxes=up;
        end
        
        %% callback is called when any of the points is moved.
        % we are going to use it to iplement it only (for now) a
        % compressor/
        function roi_callback_function(param,evt)
            % adjust all points according to the requirements:
            % fix the x-values
            up=param.myaxes;
            f=param.my_frequencies;
            %             cla(up,'reset');
            %             hold(up,'off')
            
            vv=getvalue(param);
            vv(:,1)=1:length(f);
            %             param.mypolyline = drawpolyline(up,'Position',[x;y]');
            %             clickCallback=@(src,event)roi_callback_function(param);
            %             l = addlistener(param.mypolyline,'ROIMoved',clickCallback);
            set(param.mypolyline,'Position',vv);
            for i=1:length(f)
                text(up,i,vv(i,2)+10,sprintf('%2.0f',vv(i,2)));
            end
        end
        

        
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            vv=getvalue(param);
            f=param.my_frequencies;
            mlist='[';
            mlist=[mlist sprintf('%4.0f %2.1f',f(1),vv(1))];
            for i=2:length(vv)
                mlist=[mlist sprintf(';%4.0f %2.1f',f(i),vv(i))];
            end
            mlist=[mlist,']'];
            s = sprintf('''%s'',%s',param.text,mlist);

        end
       
    end
end

