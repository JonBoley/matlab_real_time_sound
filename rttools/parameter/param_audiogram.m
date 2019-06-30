%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)



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
                       
            param.my_frequencies=vals(:,1);
            
            
        end
        
        function size=get_draw_size(param,panel)
            size(1)=300;
            size(2)=200+param.unit_scaley;
        end
        
        function vv=getvalue(param)  % get the value of this param
            if ishandle(param.mypolyline)
                v=get(param.mypolyline,'Position');
                for i=1:length(v)
                    param.value(i,2)=v(i,2);
                end
            end
            vv=param.value;
        end
        
        function setvalue(param,vv)  % get the value of this param
            param.value=vv;
            if ishandle(param.mypolyline)
                %             param.mypolyline = drawpolyline(up,'Position',[x;y]');
                %             clickCallback=@(src,event)roi_callback_function(param);
                %             l = addlistener(param.mypolyline,'ROIMoved',clickCallback);
                vvv(:,1)=1:length(param.my_frequencies);
                vvv(:,2)=vv(:,2);
                set(param.mypolyline,'Position',vvv);
            end
            param.is_changed=1;
        end
        
        function draw(param,panel,x,y)
            
            panel.Scrollable='off';
            size=get_draw_size(param,panel);
            [elem1,elem2]=getelementpositions(param,panel,x,y);
            
            up=axes(panel,'units','pixel','position',[elem1.x elem1.y+10 size(1) size(2)-50]);
            cla(up);
            hold(up,'on');
            grid(up,'on');
            
            f=param.my_frequencies;
            
            set(up,'xlim',[0.5 length(f)+0.5]);
            set(up,'ylim',[-10 100]);
            set(up,'YDir','reverse');
            set(up,'xtick',1:length(f));
            set(up,'xticklabel',f);
            set(up,'ytick',[0,20,40,60,80]);
            set(up,'yticklabel',[0,20,40,60,80]);
            audigram=getvalue(param);
            t=matlab.graphics.primitive.Text;
            t.String=param.text;
            set(up,'title',t);
            x=1:length(f);
            line(up,[0.5 length(f)+0.5],[0  0],'color','b');
            param.mypolyline = drawpolyline(up,'Position',[x' audigram(:,2)]);
            clickCallback=@(src,event)roi_callback_function(param);
            l = addlistener(param.mypolyline,'ROIMoved',clickCallback);
            param.myaxes=up;
        end
        
        %% callback is called when any of the points is moved.
        function roi_callback_function(param,evt)
            % just read the y-values and redraw the values
            v=get(param.mypolyline,'Position');
            old_v=param.value; % get the frequencies
            new_v=old_v;
            new_v(:,2)=v(:,2);
            setvalue(param,new_v);
        end
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            vv=getvalue(param);
            f=param.my_frequencies;
            mlist='[';
            mlist=[mlist sprintf('%4.0f,%2.1f',f(1),vv(1))];
            for i=2:length(vv)
                mlist=[mlist sprintf(';%4.0f,%2.1f',f(i),vv(i))];
            end
            mlist=[mlist,']'];
            s = sprintf('''%s'',%s',param.text,mlist);
            
        end
        
    end
end

