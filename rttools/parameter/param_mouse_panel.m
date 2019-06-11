%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef param_mouse_panel < parameter
    properties (SetAccess = protected)
        mypolyline;
        type;
        limits1;
        limits2;
        
    end
    
    methods (Access = public)
        
        function param=param_mouse_panel(text,vals,type)
            param@parameter(text,vals);
            if nargin<3
                param.type='generic';
            else
                param.type=type;
            end
            if isequal(param.type,'compressor')
                param.limits1(1)=0;
                param.limits2(1)=vals(3,1);
                param.limits2(2)=vals(3,2);
            end
        end
        
        function size=get_draw_size(param,panel)
            size(1)=100;
            size(2)=100+param.unit_scaley;
        end
        
        % modification of the raw values in order to get the values
        % relevant for the compressor: compressor must be set to auto
        % addupgain. return values are threshold and ratio
        function [thresh,ratio]=getcompressorvalues(param)
            vv=getvalue(param);
            thresh=vv(2,2)-vv(3,2);
            ratio=(vv(2,2)-vv(3,2))/(vv(2,1)-vv(3,1));
            ratio=1/ratio;
            ratio=max(ratio,1);
            ratio=min(ratio,50);
            thresh=min(thresh,0);
%             thresh=max(thresh,-50);
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
            
            %             val=getvalue(param);
            size=get_draw_size(param,panel);
            x1=x+param.unit_scalex; % left
            y1=y+param.unit_scalex; % top
            w1=size(1);
            h1=size(2)-param.unit_scaley;
            v=param.value;
            panel.Scrollable='off';
            
            up=axes(panel,'units','pixel','position',[x1 y1 w1 h1]);
            
            mimi=min(v(:,1));
            mama=max(v(:,1));
            d=(mama-mimi)/20;
            set(up,'xlim',[mimi-d,mama+d]);
            set(up,'ylim',[mimi-d,mama+d]);
            t=matlab.graphics.primitive.Text;
            t.String=param.text;
            set(up,'title',t);
            line(up,[mimi, mama],[mimi,mama],'color','r');
            param.mypolyline = drawpolyline(up,'Position',v);
            
            clickCallback=@(src,event)roi_callback_function(param);
            l = addlistener(param.mypolyline,'ROIMoved',clickCallback);
            
        end
        
        
        
        
        %% callback is called when any of the points is moved.
        % we are going to use it to iplement it only (for now) a
        % compressor/
        function roi_callback_function(param,evt)
            if isequal(param.type,'compressor')
                % adjust all points according to the requirements:
                % linear growth until point 2, then going to top right.
                vv=get(param.mypolyline,'Position'); % old position
                vv(1,1)=0;
                if vv(2,1)>vv(2,2) % otherwise it's an expander, not a compresor
                    vv(2,1)=vv(2,2);
                end
                vv(1,2)=vv(2,2)-vv(2,1);
                if vv(2,1)<50 % limits of compressor
                    vv(2,1)=50;
                end
                vv(3,1)=param.limits2(1);
                vv(3,2)=param.limits2(2);
                set(param.mypolyline,'Position',vv);
            end
        end
        
        %         function ret=getparamsasstring(param,str)
        %             ret=sprintf('%s=add(%s,param_mousepanel()',str,str);
        %         end
        
        
        function s=get_value_string(param)  % return the pair 'name', value, as needed for disp
            vv=getvalue(param);
            mlist='[';
            mlist=[mlist sprintf('%f %f',vv(1,1),vv(1,2))];
            for i=2:length(vv)
                mlist=[mlist sprintf(';%f %f',vv(i,1),vv(i,2))];
            end
            mlist=[mlist,']'];
            s = sprintf('''%s'',%s',param.text,mlist);
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

