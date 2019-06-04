
% audiogram x-values: 250, 500, 1000, 2000, 4000
% y-values: -10:60

%   Copyright 2019 Stefan Bleeck, University of Southampton
classdef param_audiogram < parameter
    properties (SetAccess = protected)
        mypolyline;
        myaxes;
    end
    
    methods (Access = public)
        
        function param=param_audiogram(text,val,varargin)
            param@parameter(text,val,varargin{:});
            
            param.value=val;
            
        end
        
        function size=get_draw_size(param,panel)
            size(1)=400;
            size(2)=250+param.unit_scaley;
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
            up=axes(panel,'units','pixel','position',[40 30 size(1) size(2)]);
            
            set(up,'xlim',[0.5 5.5]);
            set(up,'ylim',[-10 100]);
            set(up,'YDir','reverse');
            set(up,'xtick',1:5);
            set(up,'xticklabel',{'250','500','1K','2K','4K'});
            set(up,'ytick',[0,20,40,60,80]);
            set(up,'yticklabel',[0,20,40,60,80]);
            thresh=getvalue(param);
            t=matlab.graphics.primitive.Text;
            t.String=param.text;
            set(up,'title',t);
            x=1:5;
            y=thresh;
            line(up,[0.5 5.5],[0  0],'color','b');
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
%             cla(up,'reset');
%             hold(up,'off')       
              
            vv=getvalue(param);
            vv(:,1)=1:5;
%             param.mypolyline = drawpolyline(up,'Position',[x;y]');
%             clickCallback=@(src,event)roi_callback_function(param);
%             l = addlistener(param.mypolyline,'ROIMoved',clickCallback);
          set(param.mypolyline,'Position',vv);
            for i=1:5
                text(up,i,vv(i,2)+10,sprintf('%2.0f',vv(i,2)));
            end
        end
        
        %         function ret=getparamsasstring(param,str)
        %             ret=sprintf('%s=add(%s,param_mousepanel()',str,str);
        %         end
        
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            %             vv=getvalue(param);
            %             mlist='[';
            %             mlist=[mlist sprintf('%f %f',vv(1,1),vv(1,2))];
            %             for i=2:length(vv)
            %                 mlist=[mlist sprintf(';%f %f',vv(i,1),vv(i,2))];
            %             end
            %             mlist=[mlist,']'];
            %             s = sprintf('''%s'',%s',param.text,mlist);
            s=[];
        end
        %
        %         function disp(param)
        %             vv=param.value;
        %             mlist='[';
        %             mlist=[mlist sprintf('%f %f',vv(1,1),vv(1,2))];
        %             for i=2:length(vv)
        %                 mlist=[mlist sprintf(';%f %f',vv(i,1),vv(i,2))];
        %             end
        %             mlist=[mlist,']'];
        %             fprintf('%s (mouse panel): %d points: %s\n',param.text,length(vv),mlist);
        %         end
        %
        %         function ret= get_param_value_string(param,str) % return lines like 'setvalue(obj,'what','what')
        %
        %             vv=param.value;
        %             mlist='[';
        %             mlist=[mlist sprintf('%f %f',vv(1,1),vv(1,2))];
        %             for i=2:length(vv)
        %                 mlist=[mlist sprintf(';%f %f',vv(i,1),vv(i,2))];
        %             end
        %             mlist=[mlist,']'];
        %             ret=sprintf('setvalue(%s,''%s'',%s);',str,param.text,mlist);
        %         end
        %
    end
end

